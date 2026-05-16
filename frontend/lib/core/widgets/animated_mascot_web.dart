import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

const _viewType = 'budget-buddy-mascot';
bool _registered = false;

void _ensureRegistered() {
  if (_registered) return;
  _registered = true;
  ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
    final div = web.HTMLDivElement();
    div.style.width = '100%';
    div.style.height = '100%';
    (div as JSObject)['innerHTML'] = _kMascotSvg.toJS;
    return div;
  });
}

/// Renders the Budget Buddy mascot with full CSS + SMIL animations via the
/// browser's native SVG engine. [height] controls the bounding box; the
/// widget is always square (the SVG viewBox is 400×400).
class AnimatedMascot extends StatelessWidget {
  /// Create an [AnimatedMascot].
  const AnimatedMascot({this.height = 200, super.key});

  /// Height (and width) of the rendered mascot.
  final double height;

  @override
  Widget build(BuildContext context) {
    _ensureRegistered();
    return SizedBox.square(
      dimension: height,
      child: const HtmlElementView(viewType: _viewType),
    );
  }
}

const _kMascotSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400"
     width="100%" height="100%">
  <defs>
    <filter id="bb-glow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="5" result="blur"/>
      <feMerge>
        <feMergeNode in="blur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
    <linearGradient id="bb-cape" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#00E1FD" stop-opacity="0.8"/>
      <stop offset="100%" stop-color="#2064F9" stop-opacity="0.3"/>
    </linearGradient>
    <linearGradient id="bb-mint" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#A7E9DA"/>
      <stop offset="100%" stop-color="#32B5A0"/>
    </linearGradient>
    <linearGradient id="bb-note" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#D4F1E1"/>
      <stop offset="100%" stop-color="#88D4AB"/>
    </linearGradient>
    <clipPath id="bb-body-clip">
      <path d="M200,80 C245,80 265,130 275,180
               C295,250 310,335 200,335
               C90,335 105,250 125,180
               C135,130 155,80 200,80 Z"/>
    </clipPath>
  </defs>

  <style>
    .bb-sway {
      animation: bb-sway 3s infinite ease-in-out;
      transform-origin: 200px 80px;
    }
    @keyframes bb-sway {
      0%, 100% { transform: rotate(0deg); }
      50%       { transform: rotate(10deg); }
    }
    .bb-wave {
      animation: bb-wave 2.5s infinite ease-in-out;
      transform-origin: 285px 200px;
    }
    @keyframes bb-wave {
      0%, 100% { transform: rotate(15deg); }
      50%       { transform: rotate(35deg); }
    }
    .bb-grid {
      stroke: #ffffff;
      stroke-width: 1.5;
      stroke-opacity: 0.4;
      stroke-dasharray: 4 4;
    }
  </style>

  <!-- shadow -->
  <ellipse cx="200" cy="355" rx="90" ry="15" fill="#C0D6D0"/>

  <!-- cape -->
  <g>
    <path fill="url(#bb-cape)">
      <animate attributeName="d" dur="4s" repeatCount="indefinite"
               calcMode="spline" keyTimes="0;0.5;1"
               keySplines="0.45 0 0.55 1;0.45 0 0.55 1"
               values="M 140 160 L 80 320 Q 200 300 320 320 L 260 160 Z;
                       M 140 160 L 50 300 Q 200 270 350 300 L 260 160 Z;
                       M 140 160 L 80 320 Q 200 300 320 320 L 260 160 Z"/>
    </path>
    <path class="bb-grid">
      <animate attributeName="d" dur="4s" repeatCount="indefinite"
               calcMode="spline" keyTimes="0;0.5;1"
               keySplines="0.45 0 0.55 1;0.45 0 0.55 1"
               values="M 155 160 L 120 315;M 155 160 L 95 294;M 155 160 L 120 315"/>
    </path>
    <path class="bb-grid">
      <animate attributeName="d" dur="4s" repeatCount="indefinite"
               calcMode="spline" keyTimes="0;0.5;1"
               keySplines="0.45 0 0.55 1;0.45 0 0.55 1"
               values="M 180 160 L 160 305;M 180 160 L 150 278;M 180 160 L 160 305"/>
    </path>
    <path class="bb-grid">
      <animate attributeName="d" dur="4s" repeatCount="indefinite"
               calcMode="spline" keyTimes="0;0.5;1"
               keySplines="0.45 0 0.55 1;0.45 0 0.55 1"
               values="M 220 160 L 240 305;M 220 160 L 250 278;M 220 160 L 240 305"/>
    </path>
    <path class="bb-grid">
      <animate attributeName="d" dur="4s" repeatCount="indefinite"
               calcMode="spline" keyTimes="0;0.5;1"
               keySplines="0.45 0 0.55 1;0.45 0 0.55 1"
               values="M 245 160 L 280 315;M 245 160 L 305 294;M 245 160 L 280 315"/>
    </path>
  </g>

  <!-- left arm -->
  <g transform="rotate(25 115 200)">
    <rect x="100" y="190" width="30" height="85" rx="15" fill="url(#bb-mint)"/>
    <path d="M 100 205 Q 115 215 130 205" fill="none" stroke="#1A806D"
          stroke-width="2" opacity="0.3"/>
  </g>

  <!-- right arm (waving) -->
  <g class="bb-wave">
    <rect x="270" y="125" width="30" height="90" rx="15" fill="url(#bb-mint)"/>
    <path d="M 270 195 Q 285 205 300 195" fill="none" stroke="#1A806D"
          stroke-width="2" opacity="0.3"/>
  </g>

  <!-- legs -->
  <rect x="140" y="320" width="35" height="40" rx="10" fill="url(#bb-mint)"/>
  <rect x="225" y="320" width="35" height="40" rx="10" fill="url(#bb-mint)"/>

  <!-- body -->
  <path d="M200,80 C245,80 265,130 275,180 C295,250 310,335 200,335
           C90,335 105,250 125,180 C135,130 155,80 200,80 Z"
        fill="url(#bb-mint)"/>
  <g clip-path="url(#bb-body-clip)">
    <path d="M 90 180 Q 200 200 310 180" fill="none" stroke="#1A806D"
          stroke-width="2.5" opacity="0.25"/>
    <path d="M 70 260 Q 200 290 330 260" fill="none" stroke="#1A806D"
          stroke-width="2.5" opacity="0.25"/>
  </g>

  <!-- antenna + banknote -->
  <g class="bb-sway">
    <path d="M 200 80 Q 220 30 240 35" fill="none" stroke="#32B5A0"
          stroke-width="5" stroke-linecap="round"/>
    <g transform="translate(245,30) rotate(15)">
      <rect x="-25" y="-15" width="50" height="30" rx="2"
            fill="url(#bb-note)" stroke="#1A806D" stroke-width="1.5"/>
      <rect x="-20" y="-10" width="40" height="20" fill="none"
            stroke="#1A806D" stroke-width="1" stroke-dasharray="2 2"/>
      <text x="0" y="5" font-family="monospace" font-weight="bold"
            font-size="14" fill="#1A806D" text-anchor="middle">&#163;</text>
    </g>
  </g>

  <!-- visor -->
  <rect x="120" y="140" width="160" height="60" rx="30"
        fill="#141E28" stroke="#0B1117" stroke-width="3"/>
  <text x="160" y="183" font-family="monospace" font-weight="bold"
        font-size="40" fill="#00FFFF" text-anchor="middle"
        filter="url(#bb-glow)">&#163;</text>
  <text x="240" y="183" font-family="monospace" font-weight="bold"
        font-size="40" fill="#00FFFF" text-anchor="middle"
        filter="url(#bb-glow)">&#163;</text>
  <rect x="140" y="145" width="120" height="6" rx="3"
        fill="#ffffff" opacity="0.12"/>
</svg>
''';
