import App from "./app"
import TimeWidget from "./widgets/time"
import JenkinsWidget from "./widgets/jenkins"
import NotepadWidget from "./widgets/notepad"
import NichtLustigWidget from "./widgets/nicht_lustig"
import RedmineProjectTable from "./widgets/redmine_project_table"
import Gitter from "./widgets/gitter"
import RedmineActivityProjects from "./widgets/redmine_activity_projects"
import OwncloudImages from "./widgets/owncloud_images"

const widgets = [
Gitter,
RedmineActivityProjects,
OwncloudImages,
TimeWidget,
JenkinsWidget,
NichtLustigWidget,
RedmineProjectTable,
NotepadWidget
]

export default {
  run() {
    React.render(<App widgets={widgets}/>, document.body)
  }
}