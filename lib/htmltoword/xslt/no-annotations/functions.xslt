<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:o="urn:schemas-microsoft-com:office:office"
                xmlns:v="urn:schemas-microsoft-com:vml"
                xmlns:w10="urn:schemas-microsoft-com:office:word"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:ext="http://www.xmllab.net/wordml2html/ext"
                xmlns:java="http://xml.apache.org/xalan/java"
                xmlns:func="http://exslt.org/functions"
                version="1.0"
                exclude-result-prefixes="java msxsl ext w o v WX aml w10"
                extension-element-prefixes="func">

  <!-- support function to return substring-before or everything -->
  <func:function name="func:substring-before-if-contains">
    <xsl:param name="arg"/>
    <xsl:param name="delim"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="contains($arg, $delim)">
          <xsl:value-of select="substring-before($arg, $delim)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$arg"/>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>
</xsl:stylesheet>
