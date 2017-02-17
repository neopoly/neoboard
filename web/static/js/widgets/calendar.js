import React from "react"
import BigCalendar from "react-big-calendar"
import moment from "moment"
import WidgetMixin from "../widget_mixin"
import LastUpdatedAt from "../last_updated_at"

BigCalendar.setLocalizer(
  BigCalendar.momentLocalizer(moment)
)

export default React.createClass({
  mixins: [WidgetMixin("calendar:state")],
  getInitialState() {
    return { events: [] }
  },
  render() {
    const events = this.state.events.map(data => {
      return {
        title: data.title,
        start: moment(data.start),
        end: moment(data.end),
        allDay: true
      }
    })
    return (
      <div className="CalendarWidget">
        <BigCalendar
          events={events}
          toolbar={false}
          selectable={false}
          defaultDate={new Date()}
        />
      </div>
    )
  }
})
