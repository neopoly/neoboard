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
              return <Week week={week} events={events} key={idx}/>
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
        <button onClick={this._onPrev}>{"<"}</button>
        <span className="Focus">
          Week {formatWeekLabel(this.props.focus)}
        </span>
        <button onClick={this._onNext}>{">"}</button>
      </div>
    )
  },
  _onPrev() {
    const focus = moment(this.props.focus).subtract(1, "week")
    this.props.onFocus(focus.toDate())
  },
  _onNext() {
    const focus = moment(this.props.focus).add(1, "week")
    this.props.onFocus(focus.toDate())
  },
})

const Week = React.createClass({
  render() {
    return (
      <div className="Week">
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
  return moment(date).week()
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
              <Labels date={date}/>
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
        {this._renderDate()}
      </div>
    )
  },
  _renderDate() {
    const {date} = this.props
    return (
      <span className={`Date Day-${moment(date).date()}`}>{formatDateLabel(date)}</span>
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

    const { levels, rest } = utils.eventLevels(segments.concat(segments), EVENTS_PER_CELL)

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

function hex2rgba(hex, opacity) {
  const r = parseInt(hex.substring(1,3), 16);
  const g = parseInt(hex.substring(3,5), 16);
  const b = parseInt(hex.substring(5,7), 16);
  return `rgba(${r},${g},${b},${opacity})`
}

function colorizeEvent(event) {
  if(isUnconfirmed(event)) {
    return {
      backgroundColor: hex2rgba(event.color, 0.5),
      borderColor: event.color
    }
  }
  return {
    backgroundColor: event.color
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
