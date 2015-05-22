import React from "react"
import Board from "./board"
import connector from "./connector"

const Connected = React.createClass({
  render() {
    return <Board name="board:neo" widgets={this.props.widgets}/>
  }
})

const Connecting = React.createClass({
  render() {
    return <div>Connecting...</div>
  }
})

export default React.createClass({
  getInitialState() {
    return this.getState()
  },
  getState() {
    return {
      connected: connector.isConnected
    }
  },
  componentWillMount() {
    connector.addListener(this._connectorChanged)
    connector.establish()
  },
  render() {
    if(this.state.connected) return <Connected widgets={this.props.widgets}/>;
    else return <Connecting/>;
  },
  _connectorChanged() {
    this.setState(this.getState())
  }
})
