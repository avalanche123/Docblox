<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY CR "&#x0A;">
<!-- "xml:space='preserve'" is needed for use with libxslt -->
<!-- "xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" is needed for
     use with xsltproc -->
<!-- Used to create a blank line -->
<!ENTITY tCR "<xsl:text xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xml:space='preserve'>&CR;</xsl:text>">
<!-- Used when the line before must be ended -->
<!ENTITY tEOL "<xsl:text xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xml:space='preserve'>&CR;</xsl:text>">
<!ENTITY tSP "<xsl:text xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xml:space='preserve'> </xsl:text>">
]>

<!-- Copyright (C) 2005, 2006 Stefan Merten, David Priest Copyright (C) 2009, 
	2010 Stefan Merten xml2rst.xsl is free software; you can redistribute it 
	and/or modify it under the terms of the GNU General Public License as published 
	by the Free Software Foundation; either version 2 of the License, or (at 
	your option) any later version. This program is distributed in the hope that 
	it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
	of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
	Public License for more details. You should have received a copy of the GNU 
	General Public License along with this program; if not, write to the Free 
	Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, 
	USA. -->

<!-- ********************************************************************** -->
<!-- ********************************************************************** -->

<!-- These elements in the DTD need support: - ``colspec`` has attribute 
	"stub %yesorno; #IMPLIED" - ``document`` has attribute "title CDATA #IMPLIED" 
	Probably rendered by the `.. title::` directive -->

<!-- Set namespace extensions. These are used as [shortname]:[tag] throughout 
	the XSL-FO files. xsl: eXtensible Stylesheet Language u: user extensions 
	(indicates utility 'call-template' routines defined in these XSL files) data: 
	Data elements used by the stylesheet -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:u="u"
	xmlns:data="a" exclude-result-prefixes="data" xmlns:str="http://exslt.org/strings"
	xmlns:dyn="http://exslt.org/dynamic" xmlns:math="http://exslt.org/math"
	extension-element-prefixes="str dyn math">

	<!-- xmlns:regexp="http://exslt.org/regular-expressions" not supported :-( -->

	<xsl:output method="text" omit-xml-declaration="yes" indent="no" />
	<xsl:param name="adornment" select="'o=o-u=u-u~u`u,u.'" />

	<xsl:template name="u:underline">
		<!-- Length of the rendered(!) text -->
		<xsl:param name="length" />
		<!-- Depth 1 and 2 are document title and subtitle while depths greater 
			than 2 are normal section titles -->
		<xsl:param name="depth" />
		<xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xml:space="preserve">&#x0A;</xsl:text>
		<xsl:value-of
			select="str:padding($length, substring($adornment, 2 * ($depth - 1) + 2, 1))" />
		<xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xml:space="preserve">&#x0A;</xsl:text>
	</xsl:template>

	<xsl:template name="u:indent">
		<xsl:call-template name="u:repeat">
			<!-- TODO Indentation of lines after some directives must be indented 
				to align with the directive instead of a fixed indentation; however, this 
				is rather complicated since identation for parameters should be fixed -->
			<xsl:with-param name="length" select="3" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="u:repeat">
		<xsl:param name="length" select="0" />
		<xsl:param name="chars" select="' '" />
		<xsl:choose>
			<xsl:when test="not($length) or $length &lt;= 0 or not($chars)" />
			<xsl:otherwise>
				<xsl:variable name="string"
					select="concat($chars, $chars, $chars, $chars, $chars, $chars, $chars, $chars, $chars, $chars)" />
				<xsl:choose>
					<xsl:when test="string-length($string) >= $length">
						<xsl:value-of select="substring($string, 1, $length)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="u:repeat">
							<xsl:with-param name="length" select="$length" />
							<xsl:with-param name="chars" select="$string" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="/project" name="file">
		<xsl:apply-templates select="/project/file[@path=$path]" />
	</xsl:template>

	<xsl:template match="/project/file">
		<xsl:variable name="length" select="string-length(@path)" />
		<xsl:value-of select="@path" />
		<xsl:call-template name="u:underline">
			<xsl:with-param name="length" select="$length" />
			<xsl:with-param name="depth" select="1" />
		</xsl:call-template>
		<xsl:apply-templates select="/project/file[@path=$path]/interface" />
	</xsl:template>

	<xsl:template match="interface">
		<xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xml:space="preserve">&#x0A;</xsl:text>
		<xsl:text>.. php:interface </xsl:text>
		<xsl:value-of select="full_name" />
		<xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xml:space="preserve">&#x0A;</xsl:text>
		<xsl:apply-templates select="docblock" />
		<xsl:apply-templates select="method" />
	</xsl:template>

	<xsl:template match="docblock">
		<xsl:call-template name="u:indent"></xsl:call-template>
		<xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xml:space="preserve">&#x0A;</xsl:text>
		<xsl:call-template name="u:indent"></xsl:call-template>
		<xsl:value-of select="description" />
		<xsl:call-template name="u:indent"></xsl:call-template>
		<xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xml:space="preserve">&#x0A;</xsl:text>
	</xsl:template>

	<xsl:template match="method">
		<xsl:call-template name="u:indent"></xsl:call-template>
		<xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xml:space="preserve">&#x0A;</xsl:text>
		<xsl:call-template name="u:indent"></xsl:call-template>
		<xsl:text>.. php:method </xsl:text>
		<xsl:value-of select="name" />
		<xsl:call-template name="u:indent"></xsl:call-template>
		<xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			xml:space="preserve">&#x0A;</xsl:text>
		<xsl:apply-templates select="docblock" />
	</xsl:template>

</xsl:stylesheet>