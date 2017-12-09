import React from "react"
import moment from "moment"
import classnames from "classnames"
import WidgetMixin from "../../widget_mixin"
import * as utils from "./utils"

export default React.createClass({
  mixins: [WidgetMixin("calendar:state")],
  getDefaultProps() {
    return {
      perCell: 7, // one "event" will be used for "+X more indicator"
      weeksBefore: 1,
      weeksAfter: 2,
      navigateByWeeks: 4,
      locale: "en-GB",  // use English names but Monday-based weeks and 24h
    }
  },
  getInitialState() {
    return { events: [], current: new Date() }
  },
  componentWillMount() {
    moment.locale(this.props.locale)
  },
  render() {
    const events = this.state.events.map(mapEvent)
    const current = new Date(this.state.current)
    let focus = new Date(this.state.current)
    if (this.state.focus) focus = new Date(this.state.focus)

    const weeks = buildWeeks(
      focus,
      this.props.weeksBefore,
      this.props.weeksAfter
    )

    return (
      <div className="CalendarWidget">
        <div className="Calendar">
          <Navigation onFocus={this._focus} focus={focus} {...this.props} />
          <Weekdays week={weeks[0]} />
          <div className="Weeks">
            {weeks.map((week, idx) => {
              return (
                <Week
                  {...this.props}
                  current={current}
                  week={week}
                  events={events}
                  key={idx}
                />
              )
            })}
          </div>
        </div>
      </div>
    )
  },
  _focus(date) {
    this.setState({ focus: date })
  }
})

function mapEvent(data) {
  return Object.assign({}, data, {
    start: new Date(data.start),
    end: new Date(data.end)
  })
}

function buildWeek(around) {
  const mFrom = moment(around).startOf("week").startOf("day")
  const mTo = moment(around).endOf("week").endOf("day")
  const week = []
  for (let m = mFrom.clone(); m.isSameOrBefore(mTo); m.add(1, "day")) {
    week.push(m.toDate())
  }
  return week
}

function buildWeeks(around, before, after) {
  const weeks = []
  for (let i = before * -1; i <= after; i++) {
    const week = buildWeek(moment(around).add(7 * i, "day"))
    weeks.push(week)
  }
  return weeks
}

function eventsForWeek(events, from, to) {
  return events.filter(e => utils.inRange(e, from, to, "day"))
}

const Navigation = React.createClass({
  render() {
    return (
      <div className="Navigation">
        <button
          className="Prev"
          onClick={this._onPrev}
          title="Move back in time"
        >
          ◀
        </button>
        <span
          className="Focus"
          onClick={this._onReset}
          title="Jump to current date"
        >
          {formatMonthLabel(this.props.focus)}
        </span>
        <button
          className="Next"
          onClick={this._onNext}
          title="Move towards future"
        >
          ▶
        </button>
      </div>
    )
  },
  _onPrev() {
    const focus = moment(this.props.focus)
      .subtract(this.props.navigateByWeeks, "week")
      .toDate()
    this.props.onFocus(focus)
  },
  _onNext() {
    const focus = moment(this.props.focus)
      .add(this.props.navigateByWeeks, "week")
      .toDate()
    this.props.onFocus(focus)
  },
  _onReset() {
    this.props.onFocus(this.props.current)
  }
})

const Weekdays = React.createClass({
  render() {
    return (
      <div className="Weekdays">
        {this.props.week.map((date, idx) => {
          return (
            <div key={idx} className={`Weekday-${moment(date).day()}`}>
              {formatDayLabel(date)}
            </div>
          )
        })}
      </div>
    )
  }
})

const Week = React.createClass({
  render() {
    return (
      <div className="Week">
        <BackgroundCells {...this.props} />
        <LabelCells {...this.props} />
        <WeekEvents {...this.props} />
      </div>
    )
  }
})

const BackgroundCells = React.createClass({
  render() {
    const { current, week } = this.props
    return (
      <div className="BackgroundCells">
        {week.map((date, idx) => {
          const css = classnames("Day", `Weekday-${moment(date).day()}`, {
            isCurrentDay: moment(date).isSame(current, "day"),
            isCurrentWeek: moment(week[0]).isSame(current, "week"),
            isCurrentMonth: moment(date).isSame(current, "month"),
            isCurrentYear: moment(date).isSame(current, "year")
          })
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

function formatDayLabel(date) {
  return moment(date).format("dd")
}

function formatDateLabel(date) {
  const day = moment(date).date()
  if (day == 1) return `${formatMonthLabel(date)} ${day}`
  return day
}

function formatMonthLabel(date) {
  return moment.months()[moment(date).month()]
}

function formatWeekLabel(date) {
  return moment(date).isoWeek()
}

function formatEventDate(event) {
  const start = event.start
  const end = utils.correctedEventEnd(event)
  if (event.allDay) {
    if (moment(start).isSame(end, "days")) {
      return moment(start).format("L")
    }
    return `${moment(start).format("L")} - ${moment(end).format("L")}`
  }
  return moment(start).format("LLL")
}

const LabelCells = React.createClass({
  render() {
    return (
      <div className="LabelCells">
        {this.props.week.map((date, idx) => {
          return (
            <div
              key={idx}
              className="Label"
              style={utils.styleForSegement(1, this.props.week.length)}
            >
              <Labels date={date} current={this.props.current} />
            </div>
          )
        })}
      </div>
    )
  }
})

const Labels = React.createClass({
  render() {
    return (
      <div className="Labels">
        {this._renderWeek()}
        {this._renderDate()}
      </div>
    )
  },
  _renderDate() {
    const { current, date } = this.props
    const css = classnames("Date", `Day-${moment(date).date()}`, {
      isCurrentDay: moment(date).isSame(current, "day")
    })
    return (
      <span className={css}>
        {formatDateLabel(date)}
      </span>
    )
  },
  _renderWeek() {
    const { date } = this.props
    if (moment(date).weekday() !== 0) return null
    return (
      <span className={`CalendarWeek Week-${moment(date).isoWeek()}`}>
        {formatWeekLabel(date)}
      </span>
    )
  }
})

const WeekEvents = React.createClass({
  render() {
    const { perCell, week } = this.props
    const from = week[0]
    const to = week[week.length - 1]
    const events = eventsForWeek(this.props.events, from, to)
    events.sort((a, b) => utils.sortEvents(a, b))

    const segments = events.map(event => {
      return utils.segementizeEventBetween(event, from, to)
    })

    const allLevels = utils.eventLevels(segments)
    const { levels, rest } = utils.limitEventLevels(allLevels, perCell)

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
        {rest.length > 0 &&
          <EventRestRow segments={rest} from={from} to={to} {...this.props} />}
      </div>
    )
  }
})

const EventsRow = React.createClass({
  render() {
    let lastEnd = 1
    return (
      <div className="EventsRow">
        {this.props.segments.reduce((row, segment, idx) => {
          const key = `span_${idx}`
          const gap = segment.left - lastEnd
          if (gap) {
            row.push(renderSpan(`${key}_gap`, gap, this.props.week.length))
          }
          const content = (
            <Event
              event={segment.event}
              from={this.props.from}
              to={this.props.to}
            />
          )
          row.push(
            renderSpan(key, segment.span, this.props.week.length, content)
          )
          lastEnd = segment.right + 1
          return row
        }, [])}
      </div>
    )
  }
})

function renderSpan(key, span, slots, content = null) {
  const style = utils.styleForSegement(span, slots)
  return (
    <div key={key} className="Span" style={style}>
      {content}
    </div>
  )
}

const EventRestRow = React.createClass({
  render() {
    const { week, segments } = this.props
    return (
      <div className="EventRestRow">
        {week.map((date, idx) => {
          const events = segments
            .filter(({ event }) => {
              return utils.isOnDate(event, date)
            })
            .map(({ event }) => event)
          return (
            <div
              key={idx}
              style={utils.styleForSegement(1, week.length)}
            >
              {events.length > 0 &&
                <EventsPopOverHolder events={events}>
                  <span className="More">
                    +{events.length} more
                  </span>
                </EventsPopOverHolder>}
            </div>
          )
        })}
      </div>
    )
  }
})

function isUnconfirmed(event) {
  return !!event.title.match(/\?$/)
}

function colorizeEvent(event) {
  const color = utils.hex2components(event.color)
  const border = utils.lightenColor(color, 0.85)
  const borderRgba = utils.components2rgba(border)

  if (isUnconfirmed(event)) {
    const alternate = utils.lightenColor(color, 1.2)
    const altRgba = utils.components2rgba(alternate)
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
  render() {
    const { event, from, to } = this.props
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
      <EventsPopOverHolder
        className={className}
        style={colorizeEvent(event)}
        events={[event]}
      >
        <div className="EventTitle">
          {event.title}
        </div>
      </EventsPopOverHolder>
    )
  }
})

const EventsPopOverHolder = React.createClass({
  getInitialState() {
    return { tooltip: false }
  },
  render() {
    const className = classnames("EventsPopOverHolder", this.props.className)
    return (
      <div
        className={className}
        style={this.props.style}
        onMouseMove={this._onEnter}
        onMouseEnter={this._onEnter}
        onMouseOut={this._onExit}
      >
        {this.props.children}
        {this.state.tooltip &&
          <EventsPopOver top={this.state.top} events={this.props.events} />}
      </div>
    )
  },
  _onEnter(e) {
    const top = e.screenY > window.innerHeight / 2
    this.setState({ tooltip: true, top })
  },
  _onExit() {
    this.setState({ tooltip: false })
  }
})

const EventsPopOver = React.createClass({
  render() {
    const { events } = this.props
    const className = classnames("EventsPopOver", {
      top: this.props.top,
      bottom: !this.props.top
    })
    return (
      <div className={className}>
        <span className="Arrow" />
        <div className="Content">
          {events.map((event, idx) => {
            return (
              <div key={idx} className="EventDetails">
                <h2>
                  {event.calendar}
                </h2>
                <h3>
                  <span className="Title" style={colorizeEvent(event)}>
                    {event.title}
                  </span>
                  {isUnconfirmed(event) &&
                    <span className="Unconfirmed">(Unconfirmed)</span>}
                </h3>
                <table>
                  <tbody>
                    <tr>
                      <th>Date:</th>
                      <td>
                        {formatEventDate(event)}
                      </td>
                    </tr>
                    {event.location &&
                      <tr>
                        <th>Location:</th>
                        <td>
                          {event.location}
                        </td>
                      </tr>
                    }
                    {event.description &&
                      <tr>
                        <td colSpan={2}>
                          {event.description}
                        </td>
                      </tr>
                    }
                  </tbody>
                </table>
              </div>
            )
          })}
        </div>
      </div>
    )
  }
})
