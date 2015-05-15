import WidgetMixin from "../widget_mixin"
import LastUpdatedAt from "../last_updated_at"

export default React.createClass({
  mixins: [WidgetMixin("notepad:state")],
  getInitialState() {
    return {
      title: "",
      content: "",
      info: ""
    }
  },
  render() {
    return (
      <div className="NotepadWidget">
        <h2>{this.state.title}</h2>
        <div
          className="content"
          dangerouslySetInnerHTML={{
            __html: this._renderContent()
          }}
        />
        <p className="info">{this.state.info}</p>
        <LastUpdatedAt updated_at={this.state.updated_at}/>
      </div>
    )
  },
  _renderContent() {
    let content = this.state.content
    return content.replace(/<li>([^:]+):(.+)<\/li>/g, (_m, a, b) => {
      return `<li><span class="label">${a}</span><span class="value">${b}</li>`
    })
  }
})