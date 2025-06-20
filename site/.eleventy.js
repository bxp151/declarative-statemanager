module.exports = function (eleventyConfig) {
  eleventyConfig.addPassthroughCopy("assets");
  eleventyConfig.addPassthroughCopy("sitemap.xml");


  return {
    dir: {
      input: ".",
      output: "_site"
    },
    templateFormats: ["html"]
  };
};
