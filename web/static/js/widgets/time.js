import WidgetMixin from "../widget_mixin"

const Time = React.createClass({
  mixins: [WidgetMixin("time:state")],
  getInitialState() {
    return { now: "" };
  },
  render() {
    return (
      <div className="WidgetTime">{this.state.now}</div>
    );
  }
})

export default Time