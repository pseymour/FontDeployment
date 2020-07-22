<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:wix="http://schemas.microsoft.com/wix/2006/wi"
    exclude-result-prefixes="wix">

    <xsl:output method="xml" indent="yes" />
    <xsl:strip-space elements="*"/>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="wix:Product">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:element name="Icon" namespace="http://schemas.microsoft.com/wix/2006/wi">
                <xsl:attribute name="Id">FontIcon</xsl:attribute>
                <xsl:attribute name="SourceFile">icons\font folder.ico</xsl:attribute>
            </xsl:element>
            <xsl:element name="Property" namespace="http://schemas.microsoft.com/wix/2006/wi">
                <xsl:attribute name="Id">ARPNOMODIFY</xsl:attribute>
                <xsl:attribute name="Value">yes</xsl:attribute>
                <xsl:attribute name="Secure">yes</xsl:attribute>
            </xsl:element>
            <xsl:element name="Property" namespace="http://schemas.microsoft.com/wix/2006/wi">
                <xsl:attribute name="Id">ARPPRODUCTICON</xsl:attribute>
                <xsl:attribute name="Value">FontIcon</xsl:attribute>
            </xsl:element>
            <xsl:element name="Condition" namespace="http://schemas.microsoft.com/wix/2006/wi">
                <xsl:attribute name="Message">You must have administrator rights to install this software.</xsl:attribute>
                <xsl:text>Privileged</xsl:text>
            </xsl:element>
            <xsl:element name="MajorUpgrade" namespace="http://schemas.microsoft.com/wix/2006/wi">
                <xsl:attribute name="DowngradeErrorMessage">A newer version of [ProductName] is already installed.</xsl:attribute>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="wix:Product/@Id">
        <xsl:attribute name="Id">
            <xsl:value-of select="'*'"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="wix:Component/@Directory">
        <xsl:attribute name="Directory">
            <xsl:value-of select="'FontsFolder'"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="wix:Feature/@Id">
        <xsl:attribute name="Id">
            <xsl:value-of select="'Complete'"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="wix:Feature/@Title">
        <xsl:attribute name="Title">
            <xsl:value-of select="'Complete Installation'"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="wix:Directory[@Id='TARGETDIR']">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:element name="Directory" namespace="http://schemas.microsoft.com/wix/2006/wi">
                <xsl:attribute name="Id">FontsFolder</xsl:attribute>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="wix:Package">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:attribute name="InstallScope">perMachine</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="wix:File['ttf' = substring(@Source, string-length(@Source) - string-length('ttf') +1)]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:attribute name="TrueType">yes</xsl:attribute>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
