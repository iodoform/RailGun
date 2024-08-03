# Rail Gun & Shader

VRChat向けのレールガンの3Dモデルとシェーダーのセット

## 概要

本アセットはVRChat用のレールガンと，その軌跡を表示する専用シェーダーのセットです．

専用シェーダーを設定したオブジェクトに向けてレールガンを撃つと，オブジェクトに風穴を開けることができます．

## 使用方法

1. `Packages/RailGun/Runtime/Prefabs/RailGun.prefab`をシーンに配置する
2. 打ち抜きたいオブジェクトに`Custom>RailGun`または`Custom>RailGunFlat`シェーダーから作成したマテリアルを適用する　(Cubeのような閉じた形状のオブジェクトには`RailGun`，Planeのような開いた形状のオブジェクトには`RailGunFlat`を使う)
3. シーンに配置したレールガンのプレハブを選択し．インスペクターウィンドウからRailgunコンポーネントの`Materials`に手順2で作成したマテリアルをすべて登録する
![alt text](<img/スクリーンショット 2024-07-28 011501.png>)

## 注意点

- 複雑な形状のオブジェクトはうまく描画されない可能性があります．
- オブジェクトの前後関係がうまく表示されない場合はRenderQueueを調整すると改善する場合があります．

## ライセンス

Copyright (c) 2024 iodoform
Released under the MIT license
