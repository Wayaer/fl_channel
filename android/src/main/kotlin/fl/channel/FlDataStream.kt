package fl.channel

typealias FlDataStreamHandler<T> = (T) -> Unit

typealias FlDataStreamHandlerCancel = () -> Unit

// 自定义数据流管理器
class FlDataStream<T> {

    private val dataHandlers: MutableList<FlDataStreamHandler<T>> = ArrayList()

    // 发送数据，遍历期间允许监听器自行取消监听
    fun send(data: T) {
        dataHandlers.toList().forEach { handler -> handler(data) }
    }

    // 监听数据
    fun listen(handler: FlDataStreamHandler<T>): FlDataStreamHandlerCancel {
        dataHandlers.add(handler)
        return { cancel(handler) }
    }

    // 取消监听
    fun cancel(handler: FlDataStreamHandler<T>) {
        dataHandlers.remove(handler)
    }
}
