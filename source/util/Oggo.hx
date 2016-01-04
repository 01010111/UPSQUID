package util;

import flixel.addons.editors.ogmo.FlxOgmoLoader;

/**
 * ...
 * @author 01010111
 */
class Oggo extends FlxOgmoLoader { public function getString(TileLayer:String = "tiles"):String { return _fastXml.node.resolve(TileLayer).innerData; } }