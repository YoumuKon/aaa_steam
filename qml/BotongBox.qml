// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Fk
import Fk.Pages
import Fk.RoomElement
import Qt5Compat.GraphicalEffects

GraphicsBox {
  id: root

  property var cards: []
  property var selectedItems: []
  property string prompt : ""

  title.text: prompt !== "" ? Util.processPrompt(prompt) : ""
  width: 440
  height: 460

  property double lengthLimit : cardArea.width / 40
  property double angleLimit : 10
  property double angleTemp : 0
  property double zTemp : 0
  property int timeout: config.roomTimeout - 1

  Rectangle {
    id : cardArea

    width: 400
    height: 400
    border.color: "#FEF7D6"
    border.width: 2
    color: "#88EEEEEE"
    clip: true

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: 40

    Repeater {
      id: cardRepeater
      model: cards

      Image {
        id: cardItem

        property bool chosen: false
        property double angle: 0

        property bool known: true
        property int cid : modelData.cid
        property string name: modelData.name
        property string suit: modelData.suit
        property int number: modelData.number

        source: known ? SkinBank.getCardPicture(name) : (SkinBank.CARD_DIR + "card-back")
        scale : 0.75

        Image {
          id: suitItem
          visible: known
          source: (suit !== "" && suit !== "nosuit") ? SkinBank.CARD_SUIT_DIR + suit : ""
          x: 3
          y: 19
          width: 21
          height: 17
        }

        Image {
          id: numberItem
          visible: known
          source: (suit != "" && number > 0) ? SkinBank.CARD_DIR  + "number/" + modelData.color + "/" + number : ""
          x: 0
          y: 0
          width: 27
          height: 28
        }

        transform: Rotation {
          id: rotationTransform
          angle: angle
          origin.x: width / 2
          origin.y: height / 2
        }


        Component.onCompleted: {
          x = Math.random() * (cardArea.width - width);
          y = Math.random() * (cardArea.height - height);
         
          if (angleTemp == 0) {
            angleTemp = (index / cards.length * 360 -30 + 60 * Math.random()) % 360;
            angle = angleTemp;
          } else {
            angle = angleTemp;
            angleTemp = 0;
            known = false;
          }
          rotationTransform.angle = angle;
        }

        MouseArea {
          anchors.fill: parent
          drag.target: parent

          onPressed: {
            if (!chosen) {
              cardItem.opacity = 0.7;
              zTemp = zTemp + 0.01;
              cardItem.z = zTemp;
            }
          }

          onReleased: {
            cardItem.opacity = 1;
            var closestItem = null;
            var minDistance = lengthLimit;

            for (var i = 0; i < cardRepeater.count; i++) {
              var otherItem = cardRepeater.itemAt(i);
              if (otherItem === cardItem || otherItem.chosen || otherItem.known === cardItem.known) continue;

              var dx = cardItem.x - otherItem.x;
              var dy = cardItem.y - otherItem.y;
              var distance = Math.sqrt(dx * dx + dy * dy);

              if (distance < minDistance) {
                var angleDiff = Math.abs(cardItem.angle - otherItem.angle);
                if (angleDiff < angleLimit) {
                  minDistance = distance;
                  closestItem = otherItem;
                }
              }
            }

            if (closestItem) {
              cardItem.chosen = true;
              closestItem.chosen = true;
              cardItem.opacity = 0;
              closestItem.opacity = 0;
              cardItem.x = 999;
              closestItem.x = 999;
              selectedItems.push(cardItem);
              selectedItems.push(closestItem);

              if ((cards.length - selectedItems.length) === (cards.length % 2)) {
                finishGame();
              }
              
            }

          }

        }

      }

    }

  }

  Timer {
    interval: 1000
    repeat: true
    running: true
    onTriggered: {
      timeout--;
      if (timeout === 0) {
        finishGame();
      }
    }
  }

  function finishGame() {
    close();
    roomScene.state = "notactive";
    ClientInstance.replyToServer("", JSON.stringify(selectedItems.map(item => {
      return item.cid;
    })));
  }

  function loadData(data) {
    cards = data[0].map(cid => {
      return lcall("GetCardData", cid);
    });
    
    prompt = data[1];
  }
}

