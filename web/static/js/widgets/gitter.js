import WidgetMixin from "../widget_mixin"
import LastUpdatedAt from "../last_updated_at"

export default React.createClass({
  mixins: [WidgetMixin("gitter:state")],
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
            <ol>
              {this.state.messages.map(this._renderMessage)}
            </ol>
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
        <div className="avatar">
          <img src={message.fromUser.avatarUrlSmall}/>
        </div>
        <div className="content">
          <div className="meta">
            <span>{message.fromUser.displayName}</span>
            <span>{message.sent}</span>
          </div>
          <p>{message.text}</p>
        </div>
        <div className="clear"/>
      </li>
    )
  }
})