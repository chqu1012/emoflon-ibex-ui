/*
 * generated by Xtext 2.12.0
 */
package org.emoflon.ibex.gt.editor.ui

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration
import org.emoflon.ibex.gt.editor.ui.highlighting.GTHighlightingCalculator
import org.emoflon.ibex.gt.editor.ui.highlighting.GTHighlightingConfiguration

/**
 * Use this class to register components to be used within the Eclipse IDE.
 */
@FinalFieldsConstructor
class GTUiModule extends AbstractGTUiModule {
	def Class<? extends IHighlightingConfiguration> bindIHighlightingConfiguration () {
	    GTHighlightingConfiguration;
	}

	def Class<? extends ISemanticHighlightingCalculator> bindIdeSemanticHighlightingCalculator() {
		GTHighlightingCalculator
	}
}
