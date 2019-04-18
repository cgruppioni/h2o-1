<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:o="urn:schemas-microsoft-com:office:office"
                xmlns:v="urn:schemas-microsoft-com:vml"
                xmlns:w10="urn:schemas-microsoft-com:office:word"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:ext="http://www.xmllab.net/wordml2html/ext"
                xmlns:java="http://xml.apache.org/xalan/java"
                version="1.0"
                exclude-result-prefixes="java msxsl ext w o v w10">

  <xsl:template match="a[starts-with(@href, 'http://') or starts-with(@href, 'https://')]" name="link">
    <w:hyperlink>
      <xsl:attribute name="r:id">rId<xsl:value-of select="count(preceding::a[starts-with(@href, 'http://') or starts-with(@href, 'https://')]) + 8" /></xsl:attribute>
      <w:r>
        <xsl:comment>*** IN LINK ***</xsl:comment>
        <w:rPr>
          <w:rStyle w:val="ResourceLink"/>
          <w:color w:val="000080"/>
          <w:u w:val="single"/>
        </w:rPr>
        <w:t xml:space="preserve"><xsl:value-of select="."/></w:t>
      </w:r>
    </w:hyperlink>
  </xsl:template>
</xsl:stylesheet>
