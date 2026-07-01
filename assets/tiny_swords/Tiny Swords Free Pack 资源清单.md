# Tiny Swords (Free Pack) 资源清单

本文档整理同级目录 `Tiny Swords (Free Pack)` 下的资源内容，方便在 Godot 项目中快速查找和使用。

## 总览

- 资源包主目录：`Tiny Swords (Free Pack)`
- 顶层分类：`Buildings`、`Particle FX`、`Terrain`、`UI Elements`、`Units`
- 可直接使用的图片资源：410 个 `.png`
- 源工程资源：18 个 `.aseprite`
- Godot 导入旁文件：410 个 `.import`
- 系统隐藏文件：若干 `.DS_Store`，通常不用纳入游戏资源

说明：

- `.png` 是游戏中最常直接使用的精灵图、UI 图、地形图和动画帧图。
- `.aseprite` 是 Aseprite 源文件，适合需要重新导出、改色或调整动画时使用。
- `.import` 是 Godot 自动生成的导入配置文件，配合对应 `.png` 使用，不需要手动编辑。

## Buildings 建筑资源

路径：`Buildings`

建筑按阵营颜色拆分为 5 套：Black、Blue、Purple、Red、Yellow。每套都有相同类型的建筑图，共 8 个 PNG。

每个颜色目录包含：

- `Archery.png`：弓箭相关建筑，可用作弓兵训练所或远程单位建筑。
- `Barracks.png`：兵营建筑，适合用作基础单位生产点。
- `Castle.png`：城堡或主基地建筑，体量最大，适合作为核心建筑。
- `House1.png`、`House2.png`、`House3.png`：三种民居或小型建筑变体。
- `Monastery.png`：修道院或治疗、信仰类建筑。
- `Tower.png`：防御塔或瞭望塔建筑。

颜色目录：

- `Buildings/Black Buildings`
- `Buildings/Blue Buildings`
- `Buildings/Purple Buildings`
- `Buildings/Red Buildings`
- `Buildings/Yellow Buildings`

这一组适合做多阵营 RTS/策略游戏：建筑形状一致，颜色区分阵营。

## Particle FX 粒子与特效

路径：`Particle FX`

包含 8 个 PNG 特效图和 1 个 Aseprite 源文件：

- `Dust_01.png`、`Dust_02.png`：尘土效果，可用于单位移动、建造、采集或受击。
- `Explosion_01.png`、`Explosion_02.png`：爆炸效果，可用于建筑破坏、攻击命中或技能释放。
- `Fire_01.png`、`Fire_02.png`、`Fire_03.png`：火焰效果，可用于燃烧状态、火把、建筑损毁。
- `Water Splash.png`：水花效果，可用于水面交互、投射物落水或环境反馈。
- `Particle FX.aseprite`：上述特效的源文件。

## Terrain 地形资源

路径：`Terrain`

地形资源分为装饰物、采集资源和瓦片集三类。

### Decorations 装饰物

路径：`Terrain/Decorations`

#### Bushes 灌木

路径：`Terrain/Decorations/Bushes`

- `Bushe1.png`
- `Bushe2.png`
- `Bushe3.png`
- `Bushe4.png`
- `Bushes.aseprite`

用途：地图边缘、草地装饰、轻量遮挡物。文件名中 `Bushe` 应是资源包原始拼写。

#### Clouds 云朵

路径：`Terrain/Decorations/Clouds`

- `Clouds_01.png` 到 `Clouds_08.png`
- `Clouds.aseprite`

用途：天空层、地图氛围、菜单背景或轻量动态装饰。

#### Rocks 岩石

路径：`Terrain/Decorations/Rocks`

- `Rock1.png`
- `Rock2.png`
- `Rock3.png`
- `Rock4.png`

用途：地面障碍、地图装饰、不可通过区域提示。

#### Rocks in the Water 水中岩石

路径：`Terrain/Decorations/Rocks in the Water`

- `Water Rocks_01.png` 到 `Water Rocks_04.png`
- `Water Rocks_01.aseprite` 到 `Water Rocks_04.aseprite`

用途：水域装饰、浅滩、河岸边缘细节。

#### Rubber Duck 小黄鸭

路径：`Terrain/Decorations/Rubber Duck`

- `Rubber duck.png`
- `Rubber Duck.aseprite`

用途：水面彩蛋或轻松风格的装饰物。

### Resources 采集资源

路径：`Terrain/Resources`

#### Gold 金矿

路径：`Terrain/Resources/Gold`

`Gold Resource`：

- `Gold_Resource.png`
- `Gold_Resource_Highlight.png`
- `Gold Resource.aseprite`

用途：金矿主体资源点。`Highlight` 版本适合鼠标悬停、选中或可交互提示。

`Gold Stones`：

- `Gold Stone 1.png` 到 `Gold Stone 6.png`
- `Gold Stone 1_Highlight.png` 到 `Gold Stone 6_Highlight.png`
- `Gold Stones.aseprite`

用途：不同外观的金矿石散件，适合做资源点变体、采集阶段变化或地图装饰。

#### Meat 肉类资源

路径：`Terrain/Resources/Meat`

`Meat Resource`：

- `Meat Resource.png`

用途：肉类采集资源图标或地图资源点。

`Sheep`：

- `Sheep_Idle.png`
- `Sheep_Move.png`
- `Sheep_Grass.png`
- `Sheep.aseprite`

用途：羊的待机、移动和吃草动画资源，可作为可采集动物或地图生物。

#### Tools 工具

路径：`Terrain/Resources/Tools`

- `Tool_01.png`
- `Tool_02.png`
- `Tool_03.png`
- `Tool_04.png`

用途：采集工具、生产工具、背包物品或 UI 图标。

#### Wood 木材资源

路径：`Terrain/Resources/Wood`

`Trees`：

- `Tree1.png`
- `Tree2.png`
- `Tree3.png`
- `Tree4.png`
- `Stump 1.png`
- `Stump 2.png`
- `Stump 3.png`
- `Stump 4.png`
- `Trees.aseprite`

用途：树木和树桩，适合表现可砍伐树木、砍伐后残留状态、森林装饰。

`Wood Resource`：

- `Wood Resource.png`

用途：木材资源包或采集产物图标。

### Tileset 瓦片集

路径：`Terrain/Tileset`

- `Tilemap_color1.png`
- `Tilemap_color2.png`
- `Tilemap_color3.png`
- `Tilemap_color4.png`
- `Tilemap_color5.png`
- `Water Background color.png`
- `Water Foam.png`
- `Water Foam.aseprite`
- `Shadow.png`

用途：

- `Tilemap_color1` 到 `Tilemap_color5`：不同配色的地图瓦片，可用于草地、地面、水岸等基础地图铺设。
- `Water Background color.png`：水面背景色块或水域底层。
- `Water Foam.png`：水花、浪边或水岸泡沫。
- `Shadow.png`：阴影资源，可叠加在单位、建筑或装饰物下方。

## UI Elements 界面资源

路径：`UI Elements`

UI 分为商店展示横幅和实际 UI 元件两大块。

### UI Banners from the store page 商店页横幅

路径：`UI Elements/UI Banners from the store page`

`Banner`：

- `Banner.png`
- `Slots.png`

`Ribbons`：

- `Ribbon_Black.png`
- `Ribbon_Blue.png`
- `Ribbon_Purple.png`
- `Ribbon_Red.png`
- `Ribbon_Yellow.png`

用途：宣传页或菜单页装饰，也可以改作关卡标题、阵营标签、提示条。

### UI Elements 实际界面元件

路径：`UI Elements/UI Elements`

#### Banners 横幅

- `Banner.png`
- `Banner_Slots.png`

用途：面板标题、状态栏背景、任务栏或资源栏。

#### Bars 进度条

- `BigBar_Base.png`
- `BigBar_Fill.png`
- `SmallBar_Base.png`
- `SmallBar_Fill.png`

用途：生命值、建造进度、采集进度、技能冷却条。Base 是底框，Fill 是填充。

#### Buttons 按钮

- 大按钮：`BigBlueButton_Regular.png`、`BigBlueButton_Pressed.png`、`BigRedButton_Regular.png`、`BigRedButton_Pressed.png`
- 小圆按钮：`SmallBlueRoundButton_Regular.png`、`SmallBlueRoundButton_Pressed.png`、`SmallRedRoundButton_Regular.png`、`SmallRedRoundButton_Pressed.png`
- 小方按钮：`SmallBlueSquareButton_Regular.png`、`SmallBlueSquareButton_Pressed.png`、`SmallRedSquareButton_Regular.png`、`SmallRedSquareButton_Pressed.png`
- 极小按钮：`TinyRoundBlueButton.png`、`TinyRoundRedButton.png`、`TinySquareBlueButton.png`、`TinySquareRedButton.png`

用途：菜单按钮、动作按钮、单位命令按钮。`Regular` 是默认状态，`Pressed` 是按下状态。

#### Cursors 鼠标指针

- `Cursor_01.png`
- `Cursor_02.png`
- `Cursor_03.png`
- `Cursor_04.png`

用途：鼠标样式、选择状态、交互提示。

#### Human Avatars 人物头像

- `Avatars_01.png` 到 `Avatars_25.png`

用途：角色头像、村民头像、玩家头像、对话头像或单位信息面板。

#### Icons 图标

- `Icon_01.png` 到 `Icon_12.png`

用途：资源图标、命令图标、状态图标、背包物品图标。

#### Papers 纸张面板

- `RegularPaper.png`
- `SpecialPaper.png`

用途：任务说明、弹窗背景、信息卡片或文本面板。

#### Ribbons 缎带

- `BigRibbons.png`
- `SmallRibbons.png`

用途：标题装饰、奖励提示、阵营标识或标签背景。

#### Swords 剑图

- `Swords.png`

用途：战斗图标、攻击按钮、标题装饰。

#### Wood Table 木桌面板

- `WoodTable.png`
- `WoodTable_Slots.png`

用途：背包、商店、建造菜单或物品槽面板。

## Units 单位资源

路径：`Units`

单位按阵营颜色拆分为 5 套：Black、Blue、Purple、Red、Yellow。每套都有 5 类单位：Archer、Lancer、Monk、Pawn、Warrior。

颜色目录：

- `Units/Black Units`
- `Units/Blue Units`
- `Units/Purple Units`
- `Units/Red Units`
- `Units/Yellow Units`

### Archer 弓箭手

每个颜色目录的 `Archer` 下都有：

- `Archer_Idle.png`：待机动画。
- `Archer_Run.png`：移动动画。
- `Archer_Shoot.png`：射击动画。
- `Arrow.png`：箭矢投射物。

用途：远程攻击单位。

### Lancer 长枪兵

每个颜色目录的 `Lancer` 下都有：

- `Lancer_Idle.png`：待机动画。
- `Lancer_Run.png`：移动动画。
- `Lancer_Down_Attack.png`、`Lancer_Down_Defence.png`
- `Lancer_DownRight_Attack.png`、`Lancer_DownRight_Defence.png`
- `Lancer_Right_Attack.png`、`Lancer_Right_Defence.png`
- `Lancer_Up_Attack.png`、`Lancer_Up_Defence.png`
- `Lancer_UpRight_Attack.png`、`Lancer_UpRight_Defence.png`

用途：带方向表现的近战或防御单位，适合做阵型、冲锋、防守状态。

### Monk 僧侣

每个颜色目录的 `Monk` 下都有：

- `Idle.png`：待机动画。
- `Run.png`：移动动画。
- `Heal.png`：治疗动作动画。
- `Heal_Effect.png`：治疗特效。

用途：治疗单位、辅助单位或法术单位。

### Pawn 工人 / 村民

每个颜色目录的 `Pawn` 下都有：

- 基础动作：`Pawn_Idle.png`、`Pawn_Run.png`
- 持斧：`Pawn_Idle Axe.png`、`Pawn_Run Axe.png`、`Pawn_Interact Axe.png`
- 持锤：`Pawn_Idle Hammer.png`、`Pawn_Run Hammer.png`、`Pawn_Interact Hammer.png`
- 持刀：`Pawn_Idle Knife.png`、`Pawn_Run Knife.png`、`Pawn_Interact Knife.png`
- 持镐：`Pawn_Idle Pickaxe.png`、`Pawn_Run Pickaxe.png`、`Pawn_Interact Pickaxe.png`
- 搬运资源：`Pawn_Idle Gold.png`、`Pawn_Run Gold.png`、`Pawn_Idle Meat.png`、`Pawn_Run Meat.png`、`Pawn_Idle Wood.png`、`Pawn_Run Wood.png`

用途：采集、建造、搬运、生产类单位。动作种类非常完整，适合做基础经济系统。

### Warrior 战士

每个颜色目录的 `Warrior` 下都有：

- `Warrior_Idle.png`：待机动画。
- `Warrior_Run.png`：移动动画。
- `Warrior_Attack1.png`：攻击动作 1。
- `Warrior_Attack2.png`：攻击动作 2。
- `Warrior_Guard.png`：防御或格挡动作。

用途：基础近战战斗单位。

### Units 源文件

路径：`Units/Units (aseprite in Blue only)`

这个目录只提供蓝色单位的 Aseprite 源文件：

- `Archer.aseprite`
- `Lancer.aseprite`
- `Monk.aseprite`
- `Pawn.aseprite`
- `Warrior.aseprite`

用途：如果要重新导出动画帧、调整蓝色单位动作，或基于蓝色单位源文件制作新阵营颜色，可以从这里开始。

## 使用建议

- 做多阵营时，优先使用同名文件跨颜色目录替换，例如 `Blue Units/Warrior/Warrior_Run.png` 与 `Red Units/Warrior/Warrior_Run.png`。
- 建筑和单位都已经按颜色分组，适合直接映射成玩家阵营或敌我阵营。
- `Pawn` 的采集动作很完整，可以优先实现木材、金矿、肉类三种资源采集。
- `Bars`、`Buttons`、`Cursors`、`Icons` 可以组成一套完整的策略游戏 UI。
- `Highlight` 后缀的资源适合用作鼠标悬停、选中状态或可交互反馈。
- `.import` 文件跟随 `.png` 即可，不建议手动删除；如果重新导入资源，Godot 会根据项目设置重新生成。
