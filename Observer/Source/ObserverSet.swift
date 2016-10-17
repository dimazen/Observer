import Foundation

final class ObserverInfo<T>: Hashable {
	
	fileprivate let observer: (T) -> Void
	
	fileprivate init(_ observer: @escaping (T) -> Void) {
		self.observer = observer
	}
	
	var hashValue: Int { return Unmanaged.passUnretained(self).toOpaque().hashValue }
}

func == <T>(lhs: ObserverInfo<T>, rhs: ObserverInfo<T>) -> Bool {
	return lhs.hashValue == rhs.hashValue
}

open class ObserverSet<T> {
	
	fileprivate var lock: OSSpinLock = OS_SPINLOCK_INIT
	fileprivate var descriptors: Set<ObserverInfo<T>> = []
	
	open var notificationQueue: DispatchQueue?
	
	public init() {}
	
	open func add(_ observer: @escaping (T) -> Void) -> Disposable {
		let descriptor = ObserverInfo(observer)
		
		OSSpinLockLock(&lock)
		descriptors.insert(descriptor)
		OSSpinLockUnlock(&lock)
		
		let disposable = Disposable { [weak self, weak descriptor] in
			if let _self = self, let descriptor = descriptor {
				OSSpinLockLock(&_self.lock)
				_self.descriptors.remove(descriptor)
				OSSpinLockUnlock(&_self.lock)
			}
		}
		
		return disposable
	}
	
	open func send(_ value: T) {
		OSSpinLockLock(&lock)
		let usedDescriptors = descriptors
		OSSpinLockUnlock(&lock)
		
		if let queue = notificationQueue {
			queue.async {
				for descriptor in usedDescriptors {
					descriptor.observer(value)
				}
			}
		} else {			
			for descriptor in usedDescriptors {
				descriptor.observer(value)
			}
		}
	}
	
	open func disposeAll() {
		OSSpinLockLock(&lock)
		descriptors.removeAll()
		OSSpinLockUnlock(&lock)
	}
    
}
