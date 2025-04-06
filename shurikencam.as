// Made by Shuriken255
// Linked to the viewfinder "SHURIKEN255_CAMERA"
import flash.geom.Matrix;
import flash.events.Event;
import flash.display.DisplayObject;
import flash.utils.getQualifiedClassName;
import flash.display.MovieClip;

// Link the viewfinder to the camera
var viewfinder:MovieClip = SHURIKEN255_CAMERA;

function onEnterFrame(e:Event) {
    parent.filters = this.filters;
    cameraLogic();
}

function onUnload(e:Event) {
    resetStagePosition();
    parent.filters = new Array();
    removeEventListener(Event.ENTER_FRAME, onEnterFrame);
}

addEventListener(Event.ENTER_FRAME, onEnterFrame);
addEventListener(Event.REMOVED_FROM_STAGE, onUnload);

var binding = 1;
var bindingSymbolDefined = ApplicationDomain.currentDomain.hasDefinition("SHURIKEN255_CAMERA_BINDING_CONTROL");

function updateBinding() {
    for (var i = 0; i < parent.numChildren; i++) {
        var child:DisplayObject = parent.getChildAt(i);
        if (getQualifiedClassName(child) == "SHURIKEN255_CAMERA_BINDING_CONTROL") {
            binding = MovieClip(child).scaleX * 0.2;
            return;
        }
    }
    binding = 1;
}

var bounds:Rectangle = viewfinder.getBounds(viewfinder);
var oW = bounds.right - bounds.left;
var oH = bounds.bottom - bounds.top;
var sW = stage.stageWidth;
var sH = stage.stageHeight;
var swR = sW / oW;
var shR = sH / oH;

var point:Object = new Object();
function convertToParent(clip:MovieClip, point) {
    var m:Matrix = clip.transform.matrix;
    var newX = clip.x + point.x * m.a + point.y * m.c;
    var newY = clip.y + point.x * m.b + point.y * m.d;
    point.x = newX;
    point.y = newY;
}

function convertFromParent(clip:MovieClip, point) {
    var m:Matrix = clip.transform.matrix;
    var newX = point.x;
    var newY = point.y;
    var oldX = ((clip.x + ((clip.y - newY) / (-m.d)) * m.c - newX) / (-m.a)) / (1 - (m.b * m.c) / (m.d * m.a));
    var oldY = ((clip.y + ((clip.x - newX) / (-m.a)) * m.b - newY) / (-m.d)) / (1 - (m.c * m.b) / (m.a * m.d));
    point.x = oldX;
    point.y = oldY;
}

var prevX = x;
var prevY = y;
var prevW = scaleX;
var prevH = scaleY;
var prevR = rotation;

var defaultShakeMultiplier = 0.75;
var inverted = false;
var shakeX = 0;
var shakeY = 0;

function cameraLogic() {
    resetStagePosition();
    moveViewframe();
    attachStageToViewframe();
    shakeLogic();
    moveParallaxes();
}

function shakeLogic() {
    inverted = !inverted;
    var mul = MovieClip(parent).shuriken255_shake_multiplier;
    if (mul == undefined) {
        mul = defaultShakeMultiplier;
    }
    shakeX *= mul;
    shakeY *= mul;
}

function moveViewframe() {
    if (bindingSymbolDefined) {
        updateBinding();
    }
    viewfinder.x = 0;
    viewfinder.y = 0;
    viewfinder.scaleX = 1;
    viewfinder.scaleY = 1;
    viewfinder.rotation = -this.rotation;

    var tarX = x;
    var tarY = y;
    var tarW = scaleX;
    var tarH = scaleY;
    var tarR = rotation;
    var difR = tarR - prevR;

    while (difR < -180) { difR += 360; }
    while (difR > 180) { difR -= 360; }

    var finR = prevR + (difR) * binding;
    var finX = prevX + (tarX - prevX) * binding;
    var finY = prevY + (tarY - prevY) * binding;
    var finW = prevW + (tarW - prevW) * binding;
    var finH = prevH + (tarH - prevH) * binding;

    prevX = finX;
    prevY = finY;
    prevW = finW;
    prevH = finH;
    prevR = finR;

    if (inverted) {
        finX -= shakeX;
        finY -= shakeY;
    } else {
        finX += shakeX;
        finY += shakeY;
    }

    point.x = finX;
    point.y = finY;
    convertFromParent(this, point);
    viewfinder.x = point.x;
    viewfinder.y = point.y;

    viewfinder.scaleX = finW / scaleX;
    viewfinder.scaleY = finH / scaleY;
    viewfinder.rotation = finR - rotation;
}

cameraLogic();
