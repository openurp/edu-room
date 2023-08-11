import org.openurp.parent.Dependencies._
import org.openurp.parent.Settings._

ThisBuild / organization := "org.openurp.edu.room"
ThisBuild / version := "0.0.1-SNAPSHOT"

ThisBuild / scmInfo := Some(
  ScmInfo(
    url("https://github.com/openurp/edu-room"),
    "scm:git@github.com:openurp/edu-room.git"
  )
)

ThisBuild / developers := List(
  Developer(
    id = "chaostone",
    name = "Tihua Duan",
    email = "duantihua@gmail.com",
    url = url("http://github.com/duantihua")
  )
)

ThisBuild / description := "OpenURP Edu Room Webapp"
ThisBuild / homepage := Some(url("http://openurp.github.io/edu-room/index.html"))

val apiVer = "0.34.1"
val starterVer = "0.3.8"
val baseVer = "0.4.6"
val openurp_edu_api = "org.openurp.edu" % "openurp-edu-api" % apiVer
val openurp_base_api = "org.openurp.base" % "openurp-base-api" % apiVer
val openurp_base_tag = "org.openurp.base" % "openurp-base-tag" % baseVer
val openurp_stater_web = "org.openurp.starter" % "openurp-starter-web" % starterVer
val beangle_webmvc_view = "org.beangle.webmvc" % "beangle-webmvc-view_3" % "0.9.5-SNAPSHOT"

lazy val root = (project in file("."))
  .enablePlugins(WarPlugin, UndertowPlugin, TomcatPlugin)
  .settings(
    name := "openurp-edu-room-webapp",
    common,
    libraryDependencies ++= Seq(openurp_base_api, openurp_edu_api, beangle_webmvc_support, beangle_data_orm),
    libraryDependencies ++= Seq(beangle_ems_app, openurp_stater_web, openurp_base_tag, beangle_webmvc_view)
  )
