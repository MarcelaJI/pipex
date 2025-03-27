/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parsing.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ingjimen <ingjimen@student.42madrid.c      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/27 09:36:21 by ingjimen          #+#    #+#             */
/*   Updated: 2025/03/27 09:36:24 by ingjimen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

t_pipex	*parse_cmds(int ac, char **av, char **env)
{
	int		i;
	t_pipex	*pipex;

	i = 0;
	pipex = init_pipex_struct(ac, av);
	while (i < pipex->number_cmds)
	{
		pipex->cmds[i] = create_cmd_struct(av[i + 2], env, pipex);
		i++;
	}
	pipex->cmds[i] = NULL;
	return (pipex);
}
