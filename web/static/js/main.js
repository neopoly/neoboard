import App from "./app"
import TimeWidget from "./widgets/time"
import JenkinsWidget from "./widgets/jenkins"
import NotepadWidget from "./widgets/notepad"
import NichtLustigWidget from "./widgets/nicht_lustig"

const widgets = [
TimeWidget,
JenkinsWidget,
NotepadWidget,
NichtLustigWidget
]

export default {
  run() {
    React.render(<App widgets={widgets}/>, document.body)
  }
}