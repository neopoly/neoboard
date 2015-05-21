import WidgetMixin from "../widget_mixin"
import LastUpdatedAt from "../last_updated_at"

//uses global emojify

const FormattedRelative = ReactIntl.FormattedRelative
const ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

const Message = React.createClass({
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
    emojify.run(this.refs.body.getDOMNode())
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
            <ReactCSSTransitionGroup
              transitionName={this.props.transition}
              component="ol">
              {this.state.messages.reverse().map(this._renderMessage)}
            </ReactCSSTransitionGroup>
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