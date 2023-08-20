import Foundation

typealias FlDataStreamHandler<T> = (T) -> Void

// 定义回调方法类型的包装类
class FlDataStreamHandlerWrapper<T> {
    let handler: FlDataStreamHandler<T>

    init(handler: @escaping (T) -> Void) {
        self.handler = handler
    }
}

// 自定义数据流管理器
class FlDataStream<T> {
    private var dataHandlers: [FlDataStreamHandlerWrapper<T>] = []

    // 发送数据
    func send(data: T) {
        for wrapper in dataHandlers {
            wrapper.handler(data)
        }
    }

    // 监听数据
    @discardableResult
    func listen(handler: @escaping FlDataStreamHandler<T>) -> () -> Void {
        let wrapper = FlDataStreamHandlerWrapper<T>(handler: handler)
        dataHandlers.append(wrapper)
        return { [weak self] in
            self?.cancel(wrapper: wrapper)
        }
    }

    // 取消监听
    private func cancel(wrapper: FlDataStreamHandlerWrapper<T>) {
        if let index = dataHandlers.firstIndex(where: { $0 === wrapper }) {
            dataHandlers.remove(at: index)
        }
    }
}