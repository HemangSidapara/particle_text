import 'package:flutter/material.dart';
import 'package:particle_text/particle_text.dart';

class Preset {
  final String name;
  final ParticleConfig config;

  const Preset(this.name, this.config);
}

class IconDef {
  final String name;
  final IconData icon;
  final Color color;

  const IconDef(this.name, this.icon, this.color);
}
