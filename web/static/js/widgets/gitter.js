import React from "react"
import WidgetMixin from "../widget_mixin"
import LastUpdatedAt from "../last_updated_at"
import Emojify from "emojify"
import {FormattedRelative} from "react-intl"
import TimeoutTransitionGroup from "../timeout_transition_group"

const Message = React.createClass({
  getDefaultProps() {
    return { interval: 1000 * 60 } // 1 minute
  },
  render() {
    let message = this.props.value
    return (
      <div>
        <div className="avatar">
          <img src={message.fromUser.avatarUrlSmall}/>
        </div>
        <div className="content">
          <div className="meta">
            <span className="displayName">{message.fromUser.displayName}</span>
            <FormattedRelative value={message.sent}/>
          </div>
          <p ref="body">{message.text}</p>
        </div>
        <div className="clear"/>
      </div>
    )
  },
  componentDidMount() {
    Emojify.run(this.refs.body.getDOMNode())
    this._update()
  },
  componentWillUnmount() {
    this._clearTimeout()
  },
  _update() {
    this._clearTimeout()
    this.timeout = setTimeout(this._update, this.props.interval)
    this.forceUpdate()
  },
  _clearTimeout() {
    if(this.timeout) {
      clearTimeout(this.timeout)
      delete this.timeout
    }
  }
})

export default React.createClass({
  mixins: [WidgetMixin("gitter:state")],
  getDefaultProps() {
    return {transition: "transitionFade"}
  },
  getInitialState() {
    return {
      title: "",
      messages: []
    }
  },
  render() {
    return (
      <div className="GitterWidget">
        <h2>{this.state.title}</h2>
        <div className="scrollable">
          <div className="scrollable-content">
            <TimeoutTransitionGroup
              transitionName={this.props.transition}
              enterTimeout={500}
              leaveTimeout={500}
              component="ol">
              {this.state.messages.reverse().map(this._renderMessage)}
            </TimeoutTransitionGroup>
          </div>
        </div>
        <img src={this.state.url} />
        <LastUpdatedAt updated_at={this.state.updated_at}/>
      </div>
    )
  },
  _renderMessage(message) {
    return (
      <li key={message.id}>
        <Message value={message}/>
      </li>
    )
  }
})
