private class QueueItem<T> {

    fileprivate let value: T!
    fileprivate var next: QueueItem?

    init(_ newvalue: T?) {
        self.value = newvalue
    }
}

open class Queue<T> {

    fileprivate var _front: QueueItem<T>
    fileprivate var _back: QueueItem<T>
    var maxCapacity: Int
    var currentSize = 0

    public init(maxCapacity: Int) {
        // Insert dummy item. Will disappear when the first item is added.
        _back = QueueItem(nil)
        _front = _back
        self.maxCapacity = maxCapacity
    }

    /// Add a new item to the back of the queue.
    open func enqueue(_ value: T) {
        if self.currentSize >= maxCapacity {
            _back = QueueItem(value)
        } else {
            _back.next = QueueItem(value)
            _back = _back.next!
            self.currentSize += 1
        }
    }

    /// Return and remove the item at the front of the queue.
    open func dequeue() -> T? {
        if let newhead = _front.next {
            _front = newhead
            self.currentSize -= 1
            return newhead.value
        } else {
            self.currentSize = 0
            return nil
        }
    }

    open func isEmpty() -> Bool {
        return _front === _back
    }
}
