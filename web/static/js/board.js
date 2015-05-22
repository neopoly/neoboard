import React from "react"
import connector from "./connector"
import WidgetContainer from "./widget_container"

export default React.createClass({
  getInitialState() {
    return this.getState()
  },
  componentWillMount() {
    connector.addListener(this._connectorChanged)
    connector.join(this.props.name)
  },
  getState() {
    return {
      ready: !!this.getChannel()
    }
  },
  render() {
    if(this.state.ready) return <WidgetContainer widgets={this.props.widgets} channel={this.getChannel()}/>
    return <div>Waiting...</div>
  },
  getChannel() {
    return connector.getChannel(this.props.name)
  },
  _connectorChanged() {
    this.setState(this.getState())
  }
})