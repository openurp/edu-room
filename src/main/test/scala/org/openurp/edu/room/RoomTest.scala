package org.openurp.edu.room

import java.sql.Date
import java.time.LocalDate

object RoomTest {

	def main(args: Array[String]): Unit = {
		val beginOn = LocalDate.of(2020, 9, 19)
		val endOn = LocalDate.of(2021, 1, 15)

		val length = Date.valueOf(endOn).getTime - Date.valueOf(beginOn).getTime
		val a =Math.ceil(length / (1000 * 3600 * 24 * 7.0)).asInstanceOf[Int]
		println(a)
//		Duration.between(beginOn, endOn).dividedBy(1000 * 3600 * 24 * 7)

	}


}
