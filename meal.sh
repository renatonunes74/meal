# date=$(date "+%Y-%m-%d")
date="2023-07-26"

echo $janta
echo $almoco
echo $cafeM
echo $cafeT


while true; do
	cafeM=$(jq -r --arg date "$date" '.[] | select(.data==$date) | .refeicoes[] | select(.tipo=="Café da Manhã") | .nome' planejamento.json)
	almoco=$(jq -r --arg date "$date" '.[] | select(.data==$date) | .refeicoes[] | select(.tipo=="Almoço") | .nome' planejamento.json)
	cafeT=$(jq -r --arg date "$date" '.[] | select(.data==$date) | .refeicoes[] | select(.tipo=="Café da Tarde") | .nome' planejamento.json)
	janta=$(jq -r --arg date "$date" '.[] | select(.data==$date) | .refeicoes[] | select(.tipo=="Janta") | .nome' planejamento.json)
	escolha=$(dialog \
		--keep-tite \
		--title 'MEAL' \
		--menu "Planejamento ($date):"  \
		--stdout \
		0 0 0 \
		"Café da Manhã" "$cafeM" \
		"Almoço" "$almoco" \
		"Café da Tarde" "$cafeT" \
		"Janta" "$janta" \
		"Mudar data" "$date" \
		"Adicionar" "Adicionar planejamento"
	)

	if [ $? -ne 0 ]
	then 
		exit 1
	fi

	case $escolha in
		"Café da Manhã")
			dialog --keep-tite --msgbox "$escolha" 0 0
			;;
		"Almoço")
			dialog --keep-tite --msgbox "$almoco" 0 0
			;;
		"Café da Tarde")
			dialog --keep-tite --msgbox "$escolha" 0 0
			;;
		"Janta")
			dialog --keep-tite --msgbox "$escolha" 0 0
			;;
		"Mudar data")
			date=$(dialog --keep-tite --stdout --date-format "%Y-%m-%d" --calendar "Mudar a data do planejamento" 0 0 )
			;;
		"Adicionar")
			while true; do
				adicionarPlanejamento=$(dialog \
					--keep-tite \
					--title 'MEAL' \
					--menu "Adicionar ao planejamento:"  \
					--stdout \
					0 0 0 \
					"Nome da Receita" "$receitaNome" \
					"Tipo" "$receitaTipo" \
					"Data" "$receitaData")

		# Verificar se o usuário pressionou "Cancelar"
		if [ -z "$adicionarPlanejamento" ]; then
			break  # Se pressionar "Cancelar", sair do loop e retornar ao menu principal
		fi
		case $adicionarPlanejamento in
			"Nome da Receita")
				receitaNome=$(jq -r '.[] | .receita' receitas.json | fzf)
				;;
			"Tipo")
				receitaTipo=$(dialog \
					--keep-tite \
					--title 'MEAL' \
					--menu "Escolha o tempo"  \
					--stdout \
					0 0 0 \
					"Café da Manhã" "1" \
					"Almoço"        "2" \
					"Café da Tarde" "3" \
					"Janta"        "4")
									;;
								"Data")
									receitaData=$(dialog --keep-tite --stdout --date-format "%Y-%m-%d" --calendar "Escolha a data para o planejamento" 0 0 )
									;;
							esac

							if [ -n "$receitaNome" ] && [ -n "$receitaTipo" ] && [ -n "$receitaData" ]; then
								dialog --yesno "Confirma a criação do planejamento?" 0 0
								case $? in
									0)
										jq \
											--arg receitaNome "$receitaNome" \
											--arg receitaTipo "$receitaTipo" \
											--arg receitaData "$receitaData" \
											'. += [{
																					"data": $receitaData,
																					"refeicoes": [
																					{
																						"nome": $receitaNome,
																						"tipo": $receitaTipo
																					}
																					]
																				}
																				]' planejamento.json > planejamento.json.tmp
																				mv planejamento.json.tmp planejamento.json
																				break
																		esac
							fi

						done
						;;

					esac
				done

