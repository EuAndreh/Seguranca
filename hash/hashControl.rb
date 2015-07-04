#Classe de controle de Hash

#Requisições dos Arquivos
require_relative "SCrypt/ScryptHash"
require_relative "SHA/SHA256"
require_relative "SHA/SHA384"
require_relative "SHA/SHA512"
require_relative "MD5/MD5"
require_relative "BCrypt/BcryptHash"

#início da implementação do controlador de algoritmo de hash
class HashControl

	#Setando o padrão para os parametros, serve para deixar alguns parametro opcionais
	PARAMETROS_DEFAULT = {
		:salt => nil,
		:algorithm => nil
	}

	#Instancia da classe de controle do algoritmo desejado
	attr_accessor :algorithmInstance

	#Possibilita a instancia com somente o segredo, o resto é opcional
	def initialize contents = {:secret => secret}
		#Lança uma exceção caso o segredo seja nulo
		raise "Secret can't be null" if contents[:secret] == nil

		#Faz a junção dos valores com os default
		contents = PARAMETROS_DEFAULT.merge(contents)

		#transforma o nome do algoritmo pra caixa baixa, facilita comparação
		contents[:algorithm] = contents[:algorithm].downcase if contents[:algorithm] != nil

		#Identifica o algoritimo desejado
		#Bcrypt é utilizado como algoritmo padrão caso nenhum seja selecionado
		#Ou caso selecione um errado
		case contents[:algorithm]
		when 'scrypt'
			@algorithmInstance = ScryptHash.new contents[:secret]
		when 'sha256'
			@algorithmInstance = SHA256.new contents[:secret], contents[:salt]
		when 'sha384'
			@algorithmInstance = SHA384.new contents[:secret], contents[:salt]
		when 'sha512'
			@algorithmInstance = SHA512.new contents[:secret], contents[:salt]
		when 'md5'
			@algorithmInstance = MD5.new contents[:secret], contents[:salt]
		else
			@algorithmInstance = BcryptHash.new contents[:secret]
		end
	end

	#Abstração da comparação fornecida pela gema
	def ==(toCompare)
		#chama a função que compara a senha (texto plano) com o hash
		return @algorithmInstance == toCompare
	end
	alias_method :is_password?, :==		#atribui ao metodo o nome is_password?

	#Torna possível a manipulação do hash
	def secret
		#Retorna o hash produzido pelo algoritmo
		return @algorithmInstance.hash
	end

	#Retorna um hash map para ser salvo no banco de dados
	def prepareForSave
		return @algorithmInstance.prepareForSave.merge(:type => "hash")
	end

end