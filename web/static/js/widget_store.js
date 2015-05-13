export default class WidgetStore {
  constructor(channel, name) {
    this.channel = channel
    this.name = name
    this.state = {}
    this._listeners = []
    this._bind()
  }
  addListener(listener) {
    this._listeners.push(listener)
  }
  _bind() {
    this.channel.on(this.name, payload => {
      this.state = payload
      this._notify()
    })
  }
  _notify() {
    this._listeners.forEach(l => l())
  }
}