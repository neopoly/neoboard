import moment from "moment"

function diff(mA, mB, unit) {
  return Math.abs(mA.diff(mB, unit))
}

function isSame(mA, mB, unit) {
  return Math.abs(mA.diff(mB)) <= moment.duration(1, unit)
}

function segmentsOverlap(seg, others) {
  return others.some(other => {
    return other.left <= seg.right && other.right >= seg.left
  })
}

export function styleForSegement(span, slots){
  const per = (span / slots) * 100 + '%';
  return { flexBasis: per, maxWidth: per }
}

export function sortEvents(a, b, unit = "days") {
  const mAStart = moment(a.start)
  const mBStart = moment(b.start)
  const mAEnd   = moment(a.end)
  const mBEnd   = moment(b.end)

  const orderByStart = mAStart.startOf(unit) - mBStart.startOf(unit)
  const durationAInUnit = diff(mAStart.startOf(unit), mAEnd.endOf(unit), unit)
  const durationBInUnit = diff(mBStart.startOf(unit), mBEnd.endOf(unit), unit)

  return orderByStart // first sort by day of start
   || Math.max(durationBInUnit, 1) - Math.max(durationAInUnit, 1) // then multi-day unit first
   || !!b.allDay - !!a.allDay // then allday events
   || a.start - b.start // then ordered by start time
}

export function segementizeEventBetween(event, first, last, unit = "days") {
  const mStart = moment(event.start)
  const mEnd   = moment(event.end)
  const mFirst = moment(first).startOf(unit)
  const mLast  = moment(last).endOf(unit)
  const slots  = diff(mFirst, mLast, unit)+1

  const mFrom  = moment.max(mStart, mFirst)
  const mTo    = moment.min(mEnd, mLast)

  const padding = diff(mFirst, mFrom, unit)
  let span = Math.min(Math.max(diff(mFrom, mTo, unit), 1), slots)
  if(mTo === mLast) span += 1

  return {
    event,
    span,
    left: padding + 1,
    right: Math.max(padding + span, 1)
  }
}

function sortSegments(a, b) {
  return a.left - b.left
}

export function eventLevels(rowSegments, limit = Infinity){
  let level
  const levels = []
  const rest   = []

  for (let i = 0; i < rowSegments.length; i++) {
    const seg = rowSegments[i];

    for (level = 0; level < levels.length; level++) {
      if (!segmentsOverlap(seg, levels[level])) {
        break
      }
    }

    if (level >= limit) {
      rest.push(seg)
    } else {
      (levels[level] || (levels[level] = [])).push(seg)
    }
  }

  for (let k = 0; k < levels.length; k++) {
    levels[k].sort(sortSegments)
  }

  rest.sort(sortSegments)

  return { levels, rest }
}

export function refitRestIntoLevels({levels, rest}, limit) {
  // if we have exactly reached the limit AND we have some rest
  if (levels.length <= limit && rest.length > 0) {
    const refit = eventLevels(rest)
    // if the rest fits into a single level
    if (refit.levels.length === 1 && refit.rest.length === 0) {
      return {
        levels: levels.concat([refit.levels[0]]),
        rest: []
      }
    }
  }
  return { levels, rest }
}

export function inRange(event, from, to, unit = "days") {
  const start = event.start
  const end   = correctedEventEnd(event)

  return moment(start).isSameOrBefore(to, unit)
    && moment(end).isSameOrAfter(from, unit)
}

export function isOnDate(event, date) {
  const start = event.start
  const end   = correctedEventEnd(event)
  return moment(date).isBetween(start, end, "days", "[]")
}

export function correctedEventEnd(event) {
  if (event.allDay) {
    return moment(event.end).subtract(1, "second").toDate()
  }
  return event.end
}

export function hex2components(hex) {
  return {
    r: parseInt(hex.substring(1,3), 16),
    g: parseInt(hex.substring(3,5), 16),
    b: parseInt(hex.substring(5,7), 16)
  }
}

export function components2rgba(colorComponents, opacity = 1) {
  const {r, g, b} = colorComponents
  return `rgba(${r},${g},${b},${opacity})`
}

export function lightenColor(colorComponents, amount) {
  const {r, g, b} = colorComponents
  return {
    r: lighten(r, amount),
    g: lighten(g, amount),
    b: lighten(b, amount)
  }
}

function lighten(colorComponent, amount) {
  return Math.max(0, Math.min(255, Math.round(colorComponent * amount)))
}
