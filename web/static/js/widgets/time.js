import WidgetMixin from "../widget_mixin"

const d = function(number){
  return number < 10 ? "0"+number : number
}

const Time = React.createClass({
  getDefaultProps(){
    return {
      sep: ":"
    }
  },
  render(){
    return (
      <div>
        <span>{d(this.props.h)}</span>
        <span>{d(this.props.sep)}</span>
        <span>{d(this.props.m)}</span>
        <span>{d(this.props.sep)}</span>
        <span>{d(this.props.s)}</span>
      </div>
    );
  }
})

export default React.createClass({
  mixins: [WidgetMixin("time:state")],
  getInitialState() {
    return { now: new Date() }
  },
  render() {
    return (
      <div className="WidgetTime">
        <Time {...this.state.time}/>
      </div>
    );
  },
  transform(storeState){
    let now = new Date(storeState.now)
    return {
      time: {
        h: now.getHours(),
        m: now.getMinutes(),
        s: now.getSeconds()
      }
    }
  }
})
