# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Math
extends Node


static func signed_sqrt(x: float) -> float:
	return sign(x) * sqrt(abs(x))
