# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python2_7 python3_4 )
PYTHON_REQ_USE='threads(+)'

inherit eutils fdo-mime gnome2-utils python-any-r1 waf-utils

DESCRIPTION="An application for schematic capture and simulation of electrical circuits"
HOMEPAGE="https://ahoi.io/project/oregano"
EGIT_REPO_URI="https://github.com/drahnr/${PN}.git"
SRC_URI=""

inherit git-r3

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

CDEPEND="dev-libs/libxml2:2
	x11-libs/goocanvas:2.0
	x11-libs/gtk+:3
	x11-libs/gtksourceview:3.0
	app-text/rarian"
DEPEND="${CDEPEND}
	${PYTHON_DEPS}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}
	|| ( gnome-base/dconf gnome-base/gconf )
	sci-electronics/electronics-menu"

src_prepare() {
	epatch "${FILESDIR}/${P}-remove-schema-update.patch"
	eapply_user
}

src_compile() {
	local _mywafconfig
	[[ "${WAF_VERBOSE}" ]] && _mywafconfig="--verbose"

	local jobs="--jobs=$(makeopts_jobs)"
	echo "\"${WAF_BINARY}\" build ${_mywafconfig} ${jobs}"
	"${WAF_BINARY}" ${_mywafconfig} ${jobs} release || die "build failed"
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	fdo-mime_desktop_database_update
	elog "You'll need to emerge your prefered simulation backend"
	elog "such ngspice or gnucap for simulation to work."
	elog "As an alternative generate a netlist and use sci-electronics/spice"
	elog "from the command line for simulation."
}

pkg_postrm() {
	gnome2_schemas_update
}
