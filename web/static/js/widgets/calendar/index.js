import React from "react"
import moment from "moment"
import classnames from "classnames"
import WidgetMixin from "../../widget_mixin"
import LastUpdatedAt from "../../last_updated_at"
import * as utils from "./utils"

moment.locale("en-GB")

function mapEvent(data) {
  return {
    title: data.title,
    start: new Date(data.start),
    end: new Date(data.end),
    allDay: data.allDay,
    color: data.color,
    calendar: data.calendar
  }
}

function buildWeek(around) {
  const mFrom     = moment(around).startOf("week").startOf("day")
  const mTo       = moment(around).endOf("week").endOf("day")
  const week      = []
  for (let m = mFrom.clone(); m.isSameOrBefore(mTo); m.add(1, "day")) {
    week.push(m.toDate())
  }
  return week
}

function buildWeeks(around, before, after) {
  const weeks = []
  for(let i=before*-1; i <= after; i++) {
    const week = buildWeek(moment(around).add(7 * i, "day"))
    weeks.push(week)
  }
  return weeks
}

export default React.createClass({
  mixins: [WidgetMixin("calendar:state")],
  getInitialState() {
    return { events: [], current: new Date() }
  },
  render() {
    const events  = this.state.events.map(mapEvent)
    const current = new Date(this.state.current)
    let focus = new Date(this.state.current)
    if(this.state.focus) focus = new Date(this.state.focus)

    const weeks = buildWeeks(focus, 1, 3)

    return (
      <div className="CalendarWidget">
        <div className="Calendar">
          <Navigation onFocus={this._focus} focus={focus} {...this.props}/>
          <div className="Weeks">
            {weeks.map((week, idx) => {
              return <Week
                current={current}
                week={week}
                events={events}
                key={idx}
              />
            })}
          </div>
        </div>
      </div>
    )
  },
  _focus(date) {
    this.setState({focus: date})
  }
})

function eventsForWeek(events, from, to) {
  return events.filter(e => utils.inRange(e, from, to, "day"))
}

const Navigation = React.createClass({
  render() {
    return (
      <div className="Navigation">
        <button className="Prev" onClick={this._onPrev}>{"◀"}</button>
        <span className="Focus" onClick={this._onReset}>
          {formatMonthLabel(this.props.focus)}
        </span>
        <button className="Next" onClick={this._onNext}>{"▶"}</button>
      </div>
    )
  },
  _onPrev() {
    const focus = moment(this.props.focus).subtract(4, "week")
    this.props.onFocus(focus.toDate())
  },
  _onNext() {
    const focus = moment(this.props.focus).add(4, "week")
    this.props.onFocus(focus.toDate())
  },
  _onReset() {
    this.props.onFocus(this.props.current)
  },
})

const Week = React.createClass({
  render() {
    const {current, week, focus} = this.props
    const css = classnames("Week", {
      isCurrentWeek: moment(week[0]).isSame(current, "week")
    })
    return (
      <div className={css}>
        <BackgroundCells {...this.props} />
        <LabelCells {...this.props} />
        <WeekEvents {...this.props}/>
      </div>
    )
  }
})

const BackgroundCells = React.createClass({
  render() {
    const {current, week} = this.props
    return (
      <div className="BackgroundCells">
        {week.map((date, idx) => {
          const css = classnames(
            "Day",
            {
              isCurrentDay: moment(date).isSame(current, "day"),
              isCurrentWeek: moment(week[0]).isSame(current, "week"),
              isCurrentMonth: moment(date).isSame(current, "month"),
              isCurrentYear: moment(date).isSame(current, "year"),
            }
          )
          return (
            <div
              key={idx}
              style={utils.styleForSegement(1, week.length)}
              className={css}
            />
          )
        })}
      </div>
    )
  }
})

function formatDateLabel(date) {
  const day = moment(date).date()
  if(day == 1) return `${formatMonthLabel(date)} ${day}`
  return day
}

function formatMonthLabel(date) {
  return moment.months()[moment(date).month()]
}

function formatWeekLabel(date) {
  return moment(date).isoWeek()
}

const LabelCells = React.createClass({
  render(){
    return (
      <div className="LabelCells">
        {this.props.week.map((date, idx) => {
          return (
            <div
              key={idx}
              className="Label"
              style={utils.styleForSegement(1, this.props.week.length)}
            >
              <Labels date={date} current={this.props.current}/>
            </div>
          )
        })}
      </div>
    )
  }
})

const Labels = React.createClass({
  render(){
    return (
      <div className="Labels">
        {this._renderWeek()}
        {this._renderDate()}
      </div>
    )
  },
  _renderDate() {
    const {current, date} = this.props
    const css = classnames(
      "Date",
      `Day-${moment(date).date()}`,
      {
        isCurrentDay: moment(date).isSame(current, "day"),
      }
    )
    return (
      <span className={css}>{formatDateLabel(date)}</span>
    )
  },
  _renderWeek() {
    const {date} = this.props
    if(moment(date).weekday() !== 0) return null
    return (
      <span className={`CalendarWeek Week-${moment(date).isoWeek()}`}>{formatWeekLabel(date)}</span>
    )
  }
})

const EVENTS_PER_CELL = 8

const WeekEvents = React.createClass({
  render(){
    const from = this.props.week[0]
    const to   = this.props.week[this.props.week.length - 1]
    const events = eventsForWeek(this.props.events, from, to)
    events.sort((a, b) => utils.sortEvents(a, b))

    const segments = events.map((event) => {
      return utils.segementizeEventBetween(event, from, to)
    })

    const { levels, rest } = utils.eventLevels(segments, EVENTS_PER_CELL)

    return (
      <div className="WeekEvents">
        {levels.map((segments, idx) => {
          return (
            <EventsRow
              key={idx}
              segments={segments}
              from={from}
              to={to}
              {...this.props}
            />
          )
        })}
      </div>
    )
  }
})

const EventsRow = React.createClass({
  render(){
    let lastEnd = 1
    return (
      <div
        className="EventsRow"
      >
        {
          this.props.segments.reduce((row, segment, idx) => {
            const key = `span_${idx}`
            const gap = segment.left - lastEnd
            if(gap) {
              row.push(this._renderSpan(`${key}_gap`, gap))
            }
            const content = <Event
              event={segment.event}
              from={this.props.from}
              to={this.props.to}
            />
            row.push(this._renderSpan(key, segment.span, content))
            lastEnd = segment.right + 1
            return row
          }, [])
        }
      </div>
    )
  },
  _renderSpan(key, span, content = null) {
    const style = utils.styleForSegement(span, this.props.week.length)
    return (
      <div
        key={key}
        className="Span"
        style={style}
      >
        {content}
      </div>
    )
  }
})

function isUnconfirmed(event) {
  return !!event.title.match(/\?$/)
}

function colorizeEvent(event) {
  const color = utils.hex2components(event.color)
  const border     = utils.lightenColor(color, 0.85)
  const borderRgba = utils.components2rgba(border)

  if(isUnconfirmed(event)) {
    const alternate  = utils.lightenColor(color, 1.2)
    const altRgba    = utils.components2rgba(alternate)
    return {
      background: `repeating-linear-gradient(
        45deg,
        ${event.color},
        ${event.color} 10px,
        ${altRgba} 10px,
        ${altRgba} 20px
      )`,
      borderColor: borderRgba
    }
  }

  return {
    backgroundColor: event.color,
    borderColor: borderRgba
  }
}

const Event = React.createClass({
  render(){
    const {event, from, to} = this.props
    const className = classnames("Event", {
      isAllDay: event.allDay,
      isStarted: moment(event.start).isSameOrAfter(from, "day"),
      isEnded: moment(event.end).isSameOrBefore(to, "day"),
      isUnconfirmed: isUnconfirmed(event)
    })
    const style = {
      backgroundColor: event.color,
      borderColor: event.color
    }
    return (
      <div className={className} style={colorizeEvent(event)}>
        {event.title}
      </div>
    )
  }
})
