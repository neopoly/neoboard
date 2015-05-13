import WidgetStore from "./widget_store"

export default React.createClass({
  getInitialState() {
    return {}
  },
  render() {
    let channel = this.props.channel
    let renderWidget = function(widget, i){
      return React.createElement(widget, {channel: channel, key: i})
    }
    return (
      <div className="widgets">
        {this.props.widgets.map(renderWidget)}
      </div>
    );
  }
})