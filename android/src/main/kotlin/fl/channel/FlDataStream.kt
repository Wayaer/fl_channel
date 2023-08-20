package fl.channel

typealias FlDataStreamHandler<T> = (T) -> Unit

// 自定义数据流管理器
class FlDataStream<T> {

    private val dataHandlers: MutableList<FlDataStreamHandler<T>> = ArrayList()

    // 发送数据
    fun send(data: T) {
        for (handler in dataHandlers) {
            handler(data)
        }
    }

    // 监听数据
    fun listen(handler: FlDataStreamHandler<T>): () -> Unit {
        dataHandlers.add(handler)
        return { cancel(handler) }
    }

    // 取消监听
    private fun cancel(handler: FlDataStreamHandler<T>) {
        dataHandlers.remove(handler)
    }

}