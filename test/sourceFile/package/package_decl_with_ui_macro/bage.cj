package testPackage

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.router.*
import ohos_app_cangjie_entry.components.*
import ohos_app_cangjie_entry.components.playground.utils.*
import ohos_app_cangjie_entry.components.playground.badge.*
import ohos_app_cangjie_entry.utils.*
import std.collection.ArrayList

@Component
public class BadgePositionBar {
  // 气泡的位置
  @Link var position: BadgePosition

  // 气泡位置的文本表示
  @State var content: String = "Right"

  let options = ArrayList<String>(["RightTop", "Right", "Left"])

  func handler(position: String) {
    this.content = position
    this.parse(position)
  }

  func parse(position: String) {
    match (position) {
      case "RightTop" => this.position = BadgePosition.RightTop
      case "Right" => this.position = BadgePosition.Right
      case "Left" => this.position = BadgePosition.Left
      case _ => this.position = BadgePosition.Right
    }
  }

  func build() {
    SelectBar(
      title: "Position",
      content: content,
      options: options,
      onSelect: handler
    )
  }
}

// 使用 @Component 定制 UI 组件，@Link 变量可实现父子组件双向绑定
@Entry
@Component
public class BadgeView {
  // badge里的数字
  @State var count: Int64 = 6

  // badge里数字的颜色
  @State @Watch[setBadgeSyle] var color: UInt32 = 0xffffff

  // badge里数字字体的大小
  @State var fontSize: Int64 = 40

  // badge的大小
  @State var badgeSize: Int64 = 60

  // badge本身的背景颜色
  @State @Watch[setBadgeSyle] var badgeColor: UInt32 = COLOR_RED

  // 气泡的位置
  @State var position: BadgePosition = BadgePosition.Right

  @State var badgeStyle: BadgeStyle = BadgeStyle(
    color: Color(0xffffff),
    badgeColor: Color(COLOR_RED)
  )

  func setBadgeSyle() {
    this.badgeStyle = BadgeStyle(
      color: Color(color),
      badgeColor: Color(badgeColor)
    )
  }

  func build() {
    Scroll() {
      Column(SECTION_EXTERNAL_SPACE) {
        PageTitle(content: "Badge")

        PageDescription(content: "Badge组件用于呈现消息气泡")

        Column(SECTION_INTERNAL_SPACE) {
          SectionTitle(content: "Playground")

          Column() {
            Badge(
              BadgeParams(
                count: Int32(count),
                style: badgeStyle,
                position: position,
              )
            ) {
              Text("Message")
              .padding(right:20)
            }.borderWidth(0)
          }.codeCard().playgroundCard()

          Column(BAR_OUTER_GRID_SIZE) {
            SliderBar(
              value: count,
              sliderParams: SliderParams(0.0, 199.0, 1.0),
              title: "Count"
            )

//            SliderBar(
//              value: fontSize,
//              sliderParams: SliderParams(16.0, 60.0, 1.0),
//              title: "FontSize"
//            )

            ColorBand(
              color: color,
              title: 'Color'
            )

            foo()

//            SliderBar(
//              value: badgeSize,
//              sliderParams: SliderParams(30.0, 80.0, 1.0),
//              title: "BadgeSize"
//            )

            ColorBand(
              color: badgeColor,
              title: 'BadgeColor'
            )

            BadgePositionBar(position: position) // 这里如果没使用绑定的变量构造，需要报错
          }.padding(bottom: 50)
        }.section()
      }.pageContainer()
    }
  }
}

public func foo() {
  println("This is foo function")
}