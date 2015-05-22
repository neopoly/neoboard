import React from "react"

const d = function(number) {
  return number < 10 ? "0"+number : number
}

const MyTime = React.createClass({
  getDefaultProps() {
    return {sep: ":"}
  },
  render() {
    let t = new Date(this.props.time)
    return (
      <span className="Time">
        <span>{d(t.getHours())}</span>
        <span>{this.props.sep}</span>
        <span>{d(t.getMinutes())}</span>
      </span>
    )
  }
})

export default React.createClass({
  render() {
    return (
      <div className="updated_at">
        {this.props.updated_at ? <span>Last updated at </span> : null}
        {this.props.updated_at ? <MyTime time={this.props.updated_at}/> : null}
      </div>
    )
  }
})