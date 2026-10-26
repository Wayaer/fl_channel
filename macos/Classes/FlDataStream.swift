public typealias FlDataStreamHandler<T> = (T) -> Void
public typealias FlDataStreamHandlerCancel = () -> Void

public class FlDataStreamHandlerWrapper<T>: NSObject {
    let handler: FlDataStreamHandler<T>

    init(_ handler: @escaping FlDataStreamHandler<T>) {
        self.handler = handler
    }
}

public class FlDataStream<T>: NSObject {
    public var dataHandlers: [FlDataStreamHandlerWrapper<T>] = []

    // 发送数据
    public func send(_ data: T) {
        for wrapper in dataHandlers {
            wrapper.handler(data)
        }
    }

    // 监听数据
    public func listen(_ handler: @escaping FlDataStreamHandler<T>) -> FlDataStreamHandlerCancel {
        let wrapper = FlDataStreamHandlerWrapper<T>(handler)
        dataHandlers.append(wrapper)
        return { [weak self] in
            self?.cancel(wrapper)
        }
    }

    // 取消监听
    public func cancel(_ wrapper: FlDataStreamHandlerWrapper<T>) {
        if let index = dataHandlers.firstIndex(where: { $0 === wrapper }) {
            dataHandlers.remove(at: index)
        }
    }
}
