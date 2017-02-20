import React from "react"
import BigCalendar from "react-big-calendar"
import moment from "moment"
import classnames from "classnames"
import WidgetMixin from "../widget_mixin"
import LastUpdatedAt from "../last_updated_at"

BigCalendar.momentLocalizer(moment)

const USE_NAVIGATION_DATE_FOR_MS = 60 * 1000
const START_DAY_AT = 9
const END_DAY_AT = 17
const CULTURE="en-GB"

const MESSAGES = {
  previous: "<",
  next: ">",

  yesterday: "Yesterday",
  tomorrow: "Tomorrow",
  date: 'Date',
  time: 'Time',
  event: 'Event',
  allDay: 'All day',

  month: "Month",
  week: "Week",
  day: "Day",
  agenda: "Agenda",

  showMore: total => `+${total} …`
}

const timeRangeFormat = ({ start, end }, culture, local) => {
  return local.format(start, 'HH:mm', culture) + ' — ' + local.format(end, 'HH:mm', culture)
}

const FORMATS = {
  eventTimeRangeFormat: timeRangeFormat,
  selectRangeFormat: timeRangeFormat,
  agendaTimeRangeFormat: timeRangeFormat,
}

const Toolbar = React.createClass({
  render() {
    let { messages, label } = this.props

    return (
      <div className="rbc-toolbar">
        <div className="rbc-btn-group">
          <button
            type="button"
            onClick={this.navigate.bind(null, "PREV")}
          >
            {messages.previous}
          </button>
          <button
            type="button"
            className="rbc-btn-today"
            onClick={this.navigate.bind(null, "TODAY")}
          >
            {label}
          </button>
          <button
            type="button"
            onClick={this.navigate.bind(null, "NEXT")}
          >
            {messages.next}
          </button>
        </div>
        <div className="rbc-btn-group">
          {this.viewNamesGroup(messages)}
        </div>
      </div>
    );
  },
  navigate(action) {
    this.props.onNavigate(action)
  },
  view(view) {
    this.props.onViewChange(view)
  },
  viewNamesGroup(messages) {
    let viewNames = this.props.views
    const view = this.props.view

    if (viewNames.length == 0) return null
    return (
      viewNames.map(name =>
        <button
          type="button"
          key={name}
          className={classnames({"rbc-active": view === name})}
          onClick={this.view.bind(null, name)}
        >
          {messages[name]}
        </button>
      )
    )
  }
})

const COMPONENTS = {
  toolbar: Toolbar
}

const mapEvent = (data) => {
  return {
    title: data.title,
    start: new Date(data.start),
    end: new Date(data.end),
    allDay: data.allDay
  }
}

const adjustLastWeekToStartOfNextWeek = (date) => {
  const endOfMonth = moment(date).locale(CULTURE).endOf("month")
  // the month's last day is also the last day of a week
  // so don't adjust the calendar
  if(endOfMonth.weekday() == 6) return date
  const threshold = endOfMonth.clone().startOf("week").startOf("day")
  // the date is before the first day of the month's last week
  // so don't adjust the calendar
  if(threshold.isAfter(date)) return date
  // otherwise adjust to the start of the next month
  return moment(date).endOf("month").add(1, "day").toDate()
}

export default React.createClass({
  mixins: [WidgetMixin("calendar:state")],
  getInitialState() {
    return { events: [], current: new Date() }
  },
  render() {
    const events = this.state.events.map(mapEvent)
    const defaultDate = new Date(this.state.current)
    const min = new Date()
    min.setHours(START_DAY_AT, 0)
    const max = new Date()
    max.setHours(END_DAY_AT, 0)

    return (
      <div className="CalendarWidget">
        <BigCalendar
          events={events}
          components={COMPONENTS}
          selectable={true}
          defaultDate={defaultDate}
          date={this._date()}
          messages={MESSAGES}
          formats={FORMATS}
          popup={true}
          culture={CULTURE}
          min={min}
          max={max}
          onNavigate={this._onNavigate}
        />
      </div>
    )
  },
  // use the manual chosen date of the navigatin happend
  // in the recent past
  _date() {
    if(this.state.date &&
      (new Date() - this.state.lastNavigationAt) < USE_NAVIGATION_DATE_FOR_MS) {
      return this.state.date
    }
    return adjustLastWeekToStartOfNextWeek(new Date(this.state.current))
  },
  _onNavigate(date) {
    this.setState({date: date, lastNavigationAt: new Date()})
  }
})
