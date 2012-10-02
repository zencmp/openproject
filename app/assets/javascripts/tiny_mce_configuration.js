tinyMCE.init({
  // General options
  mode: "none",
  theme: "openproject",
  plugins: "visualblocks, autolink, lists, style, table, advlink, template, inlinepopups, contextmenu, paste, noneditable, nonbreaking, xhtmlxtras",
  //disabled_plugins: openproject, advimage, iespell, spellchecker, visualchars, advhr, searchreplace, insertdatetime, media
  // Theme options
  theme_openproject_buttons1: "template,|,undo,redo,|,cut,copy,paste,pastetext,pasteword,|,cleanup,removeformat,|,visualaid,visualblocks,code,|,hr,image,nonbreaking,tablecontrols",
  theme_openproject_buttons2: "formatselect,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,bullist,numlist,|,outdent,indent,|,blockquote,|,forecolor,backcolor,|,link,unlink,|,sub,sup,acronym",
  theme_openproject_toolbar_location: "top",
  theme_openproject_toolbar_align: "left",
  theme_openproject_statusbar_location: "bottom",
  theme_openproject_resizing: true,
  add_form_submit_trigger: true,

  // Skin options
  skin: "default",
  skin_variant: "silver",

  // Example content CSS (should be your site CSS)
  //content_css : "css/example.css",

  //templates
  template_cdate_classes : "cdate creationdate",
  template_mdate_classes : "mdate modifieddate",
  template_selected_content_classes : "selcontent",
  template_cdate_format : "%m/%d/%Y : %H:%M:%S",
  template_mdate_format : "%m/%d/%Y : %H:%M:%S",
  template_replace_values : {
      username : "Jack Black", //examples, delete them later
      staffid : "991234"
  },
  template_templates : [
    {
      title : "Contact Infoprmation Page",
      src : tinyMCE.baseURL + "/templates/contact_page.html",
      description : "Adds default contact information page."
    }
  ]
});