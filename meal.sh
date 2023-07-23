# Append an object to the array from `receitas.json` 
# and store the new JSON in `receitas.json.tmp`

Help()
{
	# Display Help
	echo "Uso: meal [options]"
	echo
	echo "Gerais"
	echo "-a, --add     Adiciona novas receitas."
	echo "-e, --edit    Edita o arquivo de receitas."
	echo "-h, --help    Mostra esse Help."
	echo "-l, --list    Lista as receitas planejadas pela data (Default: Data atual)."
	echo
}
adicionarReceita() {
	echo "Nome da Receita: "
	read receitaNome
	receitaTipo=$(jq -r '.[] | .tipo' receitas.json | sort -u | fzf)
	echo "Validade (Dias): "
	read receitaValidade
	echo "Quantidade de Porções: "
	read receitaPorcoes

	jq \
		--arg receitaNome "$receitaNome" \
		--arg receitaTipo "$receitaTipo" \
		--arg receitaValidade "$receitaValidade" \
		--arg receitaPorcoes "$receitaPorcoes" \
		'. += [
			{
				"receita": $receitaNome,
				"tipo": $receitaTipo,
				"ingredientes": {
				"nome": 0
			},
			"validade": $receitaValidade,
			"porcoes": $receitaPorcoes
		}
		]' receitas.json > receitas.json.tmp

# Replace temp file with original file.
mv receitas.json.tmp receitas.json
}
listarReceita() {
	# date=$(date "+%Y-%m-%d")
	date="2023-07-22"
	receitas=$(jq -r --arg date "$date" '.[] | select(.data==$date) | .refeicoes[].nome' planejamento.json)

	while IFS= read -r receita; do
		echo "Receita: $receita"
		jq -r --arg ref "$receita" '.[] | select(.receita==$ref)' receitas.json
	done <<< "$receitas"

}

while getopts ":hal" option; do
	case $option in
		h) # display Help
			Help
			exit;;
		a)
			adicionarReceita
			exit;;
		l)
			listarReceita
			exit;;
		\?)
			echo "Error: Opção Inválida; Consulte os argumentos via meal -h"
			exit;;
	esac
done
