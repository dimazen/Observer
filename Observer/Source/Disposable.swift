import Foundation

public final class Disposable {
	
	var _disposed: Bool = false
	public fileprivate(set) var disposed: Bool {
		get {
			let value: Bool
			OSSpinLockLock(&lock)
			value = _disposed
			OSSpinLockUnlock(&lock)
			return value
		}
		set {
			OSSpinLockLock(&lock)
			_disposed = newValue
			OSSpinLockUnlock(&lock)
		}
	}
	
	fileprivate let action: (Void) -> Void
	fileprivate var lock: OSSpinLock = OS_SPINLOCK_INIT
		
	public init(action: @escaping (Void) -> Void) {
		self.action = action
	}
	
	public init(disposable: Disposable, action: @escaping (Void) -> Void) {
		self.action = {
			disposable.dispose()
			action()
		}
	}
	
	public func dispose() {
		if !disposed {
			disposed = true
			action()
		}
	}
    
}
