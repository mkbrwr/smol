// This hasnt been robustly tested for all alignments but is a simple malloc heap implementation that
// is roughly based upon the K&R reference examples; it has a few caveats - namely it is not suitable
// for systems with more than one core and provides no thread local affinities nor does it have any
// locking to prevent concurrent access. However it is roughly suitable for implementing enough to
// heap allocate reference types in Swift.

private let MALLOC_START = UInt(0xD02A_B000)
private let MALLOC_END = UInt(0xD080_0000)

struct SingleCoreAllocator {
    static let shared = SingleCoreAllocator()

    struct State {
        var free: Chunk?

        init() {}

        init(start: UnsafeMutableRawPointer, end: UnsafeMutableRawPointer) {
            free = Chunk(
                memory: UnsafeMutableRawBufferPointer(start: start, count: end - start), next: nil)
        }
    }

    struct Chunk: Equatable {
        static var headerSize: Int {
            MemoryLayout<UnsafeMutableRawPointer?>.stride + MemoryLayout<UInt64>.stride
        }

        static var nextOffset: Int { 0 }
        static var lengthOffset: Int { MemoryLayout<UnsafeMutableRawPointer?>.stride }

        var location: UnsafeMutableRawPointer

        init(location: UnsafeMutableRawPointer) {
            self.location = location
        }

        init(memory: UnsafeMutableRawBufferPointer, next: Chunk?) {
            self.init(location: memory.baseAddress!)
            self.next = next
            self.length = memory.count
        }

        init?(pointer: UnsafeMutableRawPointer) {
            // is the pointer itself in the heap?
            guard SingleCoreAllocator.isInHeap(pointer) else {
                return nil
            }
            // rewind back to the header
            let header = pointer.advanced(by: 0 - Chunk.headerSize)
            // ensure that header is still in the heap
            guard SingleCoreAllocator.isInHeap(header) else {
                return nil
            }
            // extract the potential length
            let rawLength = header.load(fromByteOffset: Chunk.lengthOffset, as: UInt64.self)
            // ensure the length is sensibly sized
            guard let length = Int(exactly: rawLength) else {
                return nil
            }
            // guard that the length is a reasonable value (since we store the reserved amount not just the user amount)
            guard length >= Chunk.headerSize else {
                return nil
            }
            // ensure the end of the pointer is inside the heap
            guard SingleCoreAllocator.isInHeap(header.advanced(by: length)) else {
                return nil
            }
            // yolo!
            self.init(location: header)
        }

        var next: Chunk? {
            get {
                guard
                    let nextLocation = location.load(
                        fromByteOffset: Chunk.nextOffset, as: UnsafeMutableRawPointer?.self)
                else {
                    return nil
                }
                return Chunk(location: nextLocation)
            }
            nonmutating set {
                location.storeBytes(
                    of: newValue?.location, toByteOffset: Chunk.nextOffset,
                    as: UnsafeMutableRawPointer?.self)
            }
        }

        var length: Int {
            get {
                Int(location.load(fromByteOffset: Chunk.lengthOffset, as: UInt64.self))
            }
            nonmutating set {
                location.storeBytes(
                    of: UInt64(newValue), toByteOffset: Chunk.lengthOffset, as: UInt64.self)
            }
        }

        var subsequent: Chunk {
            Chunk(location: memory.baseAddress!.advanced(by: memory.count))
        }

        var memory: UnsafeMutableRawBufferPointer {
            let start = location.advanced(by: Chunk.headerSize)
            return UnsafeMutableRawBufferPointer(start: start, count: length - Chunk.headerSize)
        }

        func split(_ size: Int) -> Chunk {
            let leftSize = size + Chunk.headerSize
            let rightSize = length - leftSize

            let newChunk = Chunk(
                memory: UnsafeMutableRawBufferPointer(rebasing: memory[size...]), next: next)
            self.length = rightSize

            return newChunk
        }
    }

    static var rawStart: UnsafeMutableRawPointer {
        UnsafeMutableRawPointer(bitPattern: MALLOC_START)!
    }

    static var state: UnsafeMutablePointer<State> {
        rawStart.bindMemory(to: State.self, capacity: 1)
    }

    static var start: UnsafeMutableRawPointer {
        rawStart.advanced(by: MemoryLayout<State>.size)
    }

    static var end: UnsafeMutableRawPointer {
        UnsafeMutableRawPointer(bitPattern: MALLOC_END)!
    }

    static func isInHeap(_ pointer: UnsafeMutableRawPointer) -> Bool {
        SingleCoreAllocator.start <= pointer && pointer < SingleCoreAllocator.end
    }

    static var minReserved: Int {
        MemoryLayout<Int32>.size - Chunk.headerSize
    }

    init() {
        SingleCoreAllocator.state.initialize(
            to: State(
                start: SingleCoreAllocator.start, end: SingleCoreAllocator.end - Chunk.headerSize))
    }

    static func gcd<T: BinaryInteger>(_ a: T, _ b: T) -> T {
        var a = Swift.max(a, b)
        var b = Swift.min(a, b)
        while b != 0 {
            let r = a % b
            a = b
            b = r
        }
        return a
    }

    static func lcm<T: BinaryInteger>(_ a: T, _ b: T) -> T {
        (a * b) / gcd(a, b)
    }

    static func allocationSize(_ size: Int, alignment: Int) -> Int {
        let newAlignment = lcm(
            min(max(MemoryLayout<Chunk>.alignment, alignment), MemoryLayout<UInt64>.alignment),
            alignment)
        let newSize = size & ~(newAlignment - 1) + (size % newAlignment != 0 ? newAlignment : 0)
        precondition(newSize >= size)
        precondition(newSize % newAlignment == 0)
        return newSize
    }

    private func allocate(_ state: UnsafeMutablePointer<State>, size: Int)
        -> UnsafeMutableRawPointer?
    {
        var previous: Chunk?
        var free = state.pointee.free
        while let entry = free {
            // check if we can fit the allocation in this free list entry
            if entry.memory.count >= size {
                // check if we can split this chunk into two
                if entry.memory.count >= size + Chunk.headerSize + SingleCoreAllocator.minReserved {
                    let newChunk = entry.split(size)
                    entry.next = nil
                    if let previous {
                        previous.next = newChunk
                    } else {
                        state.pointee.free = newChunk
                    }
                } else {
                    // remove the entry from the linked list
                    if let previous {
                        previous.next = entry.next
                    } else {
                        state.pointee.free = entry.next
                    }
                }
                entry.length = size + Chunk.headerSize
                return entry.memory.baseAddress
            }
            previous = entry
            free = entry.next
        }
        return nil
    }

    func allocate(_ bytes: Int, alignment: Int) -> UnsafeMutableRawPointer? {
        precondition(bytes >= 0)
        let size = SingleCoreAllocator.allocationSize(bytes, alignment: alignment)
        return allocate(SingleCoreAllocator.state, size: size)
    }

    private func deallocate(_ state: UnsafeMutablePointer<State>, chunk: Chunk) {
        var previous: Chunk?
        var free = state.pointee.free
        // look for adjacent chunks in the list
        while let entry = free {
            if entry.subsequent == chunk {
                // subsume the chunk into this entry
                entry.length += chunk.length
                return
            } else if chunk.subsequent == entry {
                // replace the chunk with a subsumed merge
                chunk.next = entry.next
                previous?.next = chunk
                chunk.length += entry.length
                return
            }
            previous = entry
            free = entry.next
        }
        // simple add to free list
        chunk.next = state.pointee.free
        state.pointee.free = chunk
    }

    func deallocate(_ ptr: UnsafeMutableRawPointer?) {
        guard let ptr else { return }
        guard let chunk = Chunk(pointer: ptr) else {
            fatalError("Attempt to free a pointer not allocated by this allocator")
        }
        let state = SingleCoreAllocator.state
        deallocate(state, chunk: chunk)
    }
}

@_cdecl("free")
public func free(_ ptr: UnsafeMutableRawPointer?) {
    SingleCoreAllocator.shared.deallocate(ptr)
}

@_cdecl("posix_memalign")
public func posix_memalign(
    _ ptr: UnsafeMutablePointer<UnsafeMutableRawPointer?>, _ alignment: Int, _ size: Int
) -> CInt {
    guard let newPtr = SingleCoreAllocator.shared.allocate(size, alignment: alignment) else {
        return -1
    }
    ptr.pointee = newPtr
    return 0
}
