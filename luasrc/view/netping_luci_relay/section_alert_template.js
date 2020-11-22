<script type="text/javascript">
//<![CDATA[
						// Генерируем JS_объект defaultTemplates
						var defaultTemplates = <%=util.serialize_json(default_templates) %>

						// store templates in local storage
						session.setLocalData("default-alert-templates", defaultTemplates)
						session.setLocalData("custom-alert-templates", defaultTemplates)

						var alert_template = new ui.TextAreaHighlighted(defaultTemplates[event.getValue()][alert_method.getValue()], { 
							optional: true,
							datatype: "rangelength(0,256)",
							readonly: true,
							highlights: Object.keys(theAlert["template_param"]) });
						var alert_template_widget = alert_template.render()

						var key = ""; // catch % key pressed
						alert_template_widget.addEventListener('keyup', (event) => {
							key = event.key || "Escape";
							if(key == "Escape") {
								tmpl_vars.closeAllDropdowns()
								tmpl_vars_widget.parentNode.style.visibility = "hidden";
							} else {
								// save custom template to local storage
								saveTmplCustom(alert_template.getValue())
							}
						});

						// enable Custom / Default switcher
						function allowTmplEdit() {
							document.querySelector("[name='allow-tmpl-edit']").style.display = "none"
							document.querySelector("[name='tmpl-custom']").style.display = "block"
							document.querySelector("[name='tmpl-default']").style.display = "block"
							loadTmplCustom()
						}
						// load default templae to textarea
						function loadTmplDefault(eventId=undefined, channelId=undefined) {
							var tmpls = session.getLocalData("custom-alert-templates")
							var evnt_id = eventId || event.getValue() || undefined
							var chnl_id = channelId || alert_method.getValue() || undefined
							alert_template.getTextArea().readOnly = true;

							if(evnt_id && chnl_id) {
								var storedTmpls = session.getLocalData("default-alert-templates")			
								alert_template.setValue(storedTmpls[evnt_id][chnl_id])
							} else {
								alert_template.setValue("")
							}

							document.querySelector("[name='tmpl-custom']").style.backgroundImage = "none";
							document.querySelector("[name='tmpl-default']").style.backgroundImage = "url(/luci-static/resources/icons/check-grey.png)";
						}

						// load custom template to textarea
						function loadTmplCustom(eventId=undefined, channelId=undefined) {
							var tmpls = session.getLocalData("custom-alert-templates")
							var evnt_id = eventId || event.getValue() || undefined
							var chnl_id = channelId || alert_method.getValue() || undefined
							alert_template.getTextArea().readOnly = false;

							if(evnt_id && chnl_id) {
								var storedTmpls = session.getLocalData("custom-alert-templates")
								alert_template.setValue(storedTmpls[evnt_id][chnl_id] + "\n")
							} else {
								alert_template.setValue("")
							}
							alert_template.getTextArea().focus()

							document.querySelector("[name='tmpl-default']").style.backgroundImage = "none";
							document.querySelector("[name='tmpl-custom']").style.backgroundImage = "url(/luci-static/resources/icons/check.png)";
						}

						function saveTmplCustom(tmpltext, eventId=undefined, channelId=undefined) {
							var tmpls = session.getLocalData("custom-alert-templates")
							var evnt_id = eventId || event.getValue() || "1"
							var chnl_id = channelId || alert_method.getValue() || "sms"
							tmpls[evnt_id][chnl_id] = tmpltext
							session.setLocalData("custom-alert-templates", tmpls)
						}


						var already = false; // avoid fire event twice
						function insertTmplVar() {
							return	L.bind(function(ev) {
								if(!already) {
									already = true;
									var tVar = tmpl_vars.getValue() || false
									var pos = alert_template.getTextArea().selectionEnd;
									if (pos >= 1 && tVar) {
										var oldVal = alert_template.getValue();
										var newVal = oldVal.substr(0, pos-1) + " " + tmpl_vars.getValue() + " " + oldVal.substr(pos);
										alert_template.setValue(newVal);
										// save custom template to local storage
										saveTmplCustom(newVal)
										alert_template.getTextArea().focus();
									}
									tmpl_vars.setValue("")
									tmpl_vars_widget.parentNode.style.visibility = "hidden";
								}
							})
						}
						
						alert_template.registerEvents(tmpl_vars_widget, "tmpl-var-selected", ["cbi-dropdown-change", "keyup"]);
						alert_template_widget.addEventListener('tmpl-var-selected', insertTmplVar(), false);

						alert_template.registerEvents(event_widget, "event-selected", ["cbi-dropdown-change"]);
						alert_template_widget.addEventListener('event-selected', L.bind(function(ev) { loadTmplDefault() }), false);

						alert_template.registerEvents(alert_method_widget, "alert-method-selected", ["cbi-dropdown-change"]);
						alert_template_widget.addEventListener('alert-method-selected', L.bind(function(ev) { loadTmplDefault() }), false);

						tmpl_vars.registerEvents(alert_template_widget, "on-speckey-pressed", ["keyup"])
						tmpl_vars_widget.addEventListener('on-speckey-pressed', L.bind(function(ev) {
							already = false;
							if(key == "Escape") {
								tmpl_vars.closeAllDropdowns()
								ev.target.parentNode.style.visibility = "hidden";
							} else if(key=="%") {
								var coordinates = getCaretCoordinates(alert_template.getTextArea(), alert_template.getTextArea().selectionEnd);
								var scrollTextArea_Y = alert_template.getTextArea().scrollTop;
								ev.target.parentNode.style.left = - 10 + coordinates.left + "px";
								ev.target.parentNode.style.top = 15 + coordinates.top - scrollTextArea_Y + "px";
								ev.target.parentNode.style.visibility = "visible";
								key = "";
							} else if(key != "Shift") {
								ev.target.parentNode.style.visibility = "hidden";
							}
						}));

//]]>
</script>