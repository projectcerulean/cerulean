// This file is part of Project Cerulean <https://projectcerulean.org>
// Copyright (C) 2021-2024 Martin Gulliksson
// SPDX-License-Identifier: GPL-3.0-or-later

float inverse_mix(float from, float to, float value) {
	return (value - from) / (to - from);
}


float remap(float value, float istart, float istop, float ostart, float ostop) {
	return mix(ostart, ostop, inverse_mix(istart, istop, value));
}