import WidgetMixin from "../widget_mixin"

const d = function(number) {
  return number < 10 ? "0"+number : number
}

const days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
const weekday = function(day) {
  return days[day]
}

const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
const month = function(month) {
  return months[month]
}

const MyTime = React.createClass({
  getDefaultProps() {
    return {
      sep: ":"
    }
  },
  render() {
    return (
      <div className="Time">
        <span>{d(this.props.h)}</span>
        <span>{this.props.sep}</span>
        <span>{d(this.props.m)}</span>
        <span>{this.props.sep}</span>
        <span>{d(this.props.s)}</span>
      </div>
    );
  }
})

const MyDate = React.createClass({
  getDefaultProps() {
    return {
      sep: " "
    }
  },
  render() {
    return (
      <div className="Date">
        <span>{weekday(this.props.w)}</span>
        <span>{this.props.sep}</span>
        <span>{month(this.props.m)}</span>
        <span>{this.props.sep}</span>
        <span>{d(this.props.d)}</span>
        <span>{this.props.sep}</span>
        <span>{d(this.props.y)}</span>
      </div>
    );
  }
})

export default React.createClass({
  mixins: [WidgetMixin("time:state")],
  getInitialState() {
    return {
      time: {h: 0, m: 0, s: 0},
      date: {d: 0, m: 0, y: 0}
    }
  },
  render() {
    return (
      <div className="TimeWidget">
        <MyDate {...this.state.date}/>
        <MyTime {...this.state.time}/>
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
      },
      date: {
        d: now.getDate(),
        w: now.getDay(),
        m: now.getMonth(),
        y: now.getFullYear()
      }
    }
  }
})
