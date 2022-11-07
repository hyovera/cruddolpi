<?php

namespace App\Http\Controllers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\File;

class AuthController extends Controller
{
    // postman http://127.0.0.1:8000/api/login
    public function listar()
    {
        $personas = DB::select('select *from libros');

        $response = [
            'data' => $personas,
            'res' => false,
        ];

        return response($response, 200);

        /* if ($id != 0) {
            $personas = DB::select(
                "SELECT * FROM empleos where estado=1 and visualizacion='$id' ORDER BY fechacreacion DESC "
            );
            if (count($personas) > 0) {
                $response = [
                    'data' => $personas,
                    'res' => true,
                ];
                return response($response, 200);
            } else {
                $response = [
                    'data' => $personas,
                    'res' => false,
                ];

                return response($response, 200);
            }
        } else {
            $personas = DB::select(
                'SELECT * FROM empleos where estado=1  ORDER BY fechacreacion DESC '
            );
            if (count($personas) > 0) {
                $response = [
                    'data' => $personas,
                    'res' => true,
                ];
                return response($response, 200);
            } else {
                $response = [
                    'data' => $personas,
                    'res' => false,
                ];

                return response($response, 200);
            }
        } */
    }

    public function registrar(Request $request)
    {
        $rules = [
            'name' => 'required|string|unique:user,name',
            'email' => 'required',
            'password' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            $response = [
                'msj' => 0,
                'error' => $validator->errors(),
            ];

            return response($response, 201);
        } else {
            $users = DB::insert(
                'INSERT INTO `user` (`name`, `email`, `password`, `updated_at`)  values (?,?,?,?)',
                [
                    $request['name'],
                    $request['email'],
                    $request['password'],
                    now(),
                ]
            );

            $json = [
                'msj' => 1,
                'status' => 200,
                'detalle' => 'Registro correcto',
                'count' => $users,
            ];
            return response($json, 200);
        }
    }

    public function RegistrarUsuarioEmpleado(Request $request)
    {
        $rules = [
            'usuario' => 'required|string|unique:usuario,nombreusuario',
            'clave' => 'required',
            'nombres' => 'required',
            'dni' => 'required|integer|unique:empleado,dni',
            'direccion' => 'required',
            'edad' => 'required|integer',
            'perfil' => 'required|string',
            'email' => 'required|email|unique:empleado,email',
            'imagen' => 'required|mimes:pdf',
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            $response = [
                'msj' => false,
                'msg' => 'ok',
                'detalle' => 'error',
                'error' => $validator->errors(),
            ];

            return response($response, 400);
        } else {
            $usuario = $request['usuario'];
            $clave = $request['clave'];
            $nombres = $request['nombres'];
            $dni = $request['dni'];
            $direccion = $request['direccion'];
            $edad = $request['edad'];
            $perfil = $request['perfil'];
            $email = $request['email'];
            $imagen = $request->file('imagen');
            $telefono = $request['telefono'];

            //echo $imagen;

            //exit();
            $users = DB::insert(
                'insert into usuario (nombreusuario, clave, estado, tipo, fechacreacion) values (?,?,?,?,?)',
                [$usuario, $clave, 1, 2, now()]
            );

            $id = DB::getPdo()->lastInsertId();
            $imagen_path = rand() . '' . time() . '.pdf';
            Storage::disk('images')->put($imagen_path, File::get($imagen));

            $users1 = DB::insert(
                'insert into empleado (nombre, idusuario, dni, direccion, rutacv, edad, perfil, email,telefono) values (?,?,?,?,?,?,?,?,?)',
                [
                    $nombres,
                    $id,
                    $dni,
                    $direccion,
                    $imagen_path,
                    $edad,
                    $perfil,
                    $email,
                    $telefono,
                ]
            );

            $response = [
                'msj' => true,
                'msg' => 'ok',
                'detalle' => $users1,
                'error' => $validator->errors(),
            ];

            return response($response, 200);
        }
    }

    public function RegistrarUsuarioEmpresa(Request $request)
    {
        $rules = [
            'usuario' => 'required|string|unique:usuario,nombreusuario',
            'clave' => 'required',
            'nombre' => 'required',
            'ruc' => 'required|string|unique:empresa,ruc',
            'razonsocial' => 'required',
            'rubro' => 'required',
            'email' => 'required|string|unique:empresa,email',
            'telefono' => 'required|integer',
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            $response = [
                'msj' => false,
                'msg' => 'ok',
                'detalle' => 'error',
                'error' => $validator->errors(),
            ];

            return response($response, 400);
        } else {
            $usuario = $request['usuario'];
            $clave = $request['clave'];
            $nombre = $request['nombre'];
            $ruc = $request['ruc'];
            $razonsocial = $request['razonsocial'];
            $rubro = $request['rubro'];
            $email = $request['email'];
            $telefono = $request['telefono'];

            //telefono

            //  return response($response, 200);
        }
    }

    public function EmpleosActivos($id)
    {
        if ($id != 0) {
            $personas = DB::select(
                "SELECT E.idempleo as idempleo, EM.idempresa as idempresa ,E.nombre as empleo, EM.nombre as empresa,E.pefil descri FROM empleos as E inner join empresa as EM on E.idempresa=EM.idempresa  where E.estado=1 and E.visualizacion='$id' ORDER BY E.fechacreacion DESC "
            );
            if (count($personas) > 0) {
                $response = [
                    'data' => $personas,
                    'res' => true,
                ];
                return response($response, 200);
            } else {
                $response = [
                    'data' => $personas,
                    'res' => false,
                ];

                return response($response, 200);
            }
        } else {
            $personas = DB::select(
                'SELECT E.idempleo as idempleo, EM.idempresa as idempresa, E.nombre as empleo, EM.nombre as empresa,E.pefil descri FROM empleos as E inner join empresa as EM on E.idempresa=EM.idempresa  where E.estado=1  ORDER BY E.fechacreacion DESC'
            );
            if (count($personas) > 0) {
                $response = [
                    'data' => $personas,
                    'res' => true,
                ];
                return response($response, 200);
            } else {
                $response = [
                    'data' => $personas,
                    'res' => false,
                ];

                return response($response, 200);
            }
        }
    }

    public function login(Request $request)
    {
        $rules = [
            'nombreusuario' => 'required',
            'password' => 'required',
            'tipo' => 'required',
        ];

        $tipo = $request['tipo'];
        $usuario = $request['nombreusuario'];
        $password = $request['password'];
        //  empresa
        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            $response = [
                'msj' => false,
                'msg' => 'ok',
                'detalle' => 'error',
                'error' => $validator->errors(),
            ];

            return response($response, 400);
        } else {
            if ($tipo == 1) {
                $personas = DB::select(
                    "SELECT
                    U.tipo as perfilUsuario,
                    E.idempresa as idempresa,
                    U.nombreusuario as username,
                    U.estado as verificado,
                    E.nombre as nombre,
                    E.razonsocial as razon,
                    E.rubro as rubro,
                    E.email as email
                    FROM
                    usuario as U inner join
                    empresa as E on U.idusuario=E.idusuario
                    where U.nombreusuario='$usuario' and U.clave='$password' "
                );

                if (count($personas) > 0) {
                    foreach ($personas as $value) {
                        $perfilUsuario = $value->perfilUsuario;
                        $idempresa = $value->idempresa;
                        $usuario = $value->username;
                        $verificado = $value->verificado;
                        $nombre = $value->nombre;
                        $razon = $value->razon;
                        $rubro = $value->rubro;
                        $email = $value->email;

                        if ($verificado == 0) {
                            $dataenviof = [];
                            $dataenviof['detalle'] =
                                'Usuario no validado por La Municpalidad';
                            $dataenviof['message'] = false;
                        } else {
                            $arr_inciQui[] = [
                                'idempresa' => $idempresa,
                                'usuario' => $usuario,
                                'nombre' => $nombre,
                                'razon' => $razon,
                                'rubro' => $rubro,
                                'email' => $email,
                                'perfilUsuario' => $perfilUsuario,
                            ];
                            $dataenviof = [];
                            $dataenviof['detalle'] = 'ok';
                            $dataenviof['message'] = true;
                            // 'error'
                            $dataenviof['error'] = false;
                            $dataenviof['data'] = $arr_inciQui;
                        }
                    }

                    return response($dataenviof, 200);
                } else {
                    $dataenviof = [];
                    $dataenviof['detalle'] = 'No registrado';
                    $dataenviof['message'] = false;
                    $dataenviof['error'] = false;
                    $dataenviof['data'] = '';
                    return response($dataenviof, 200);
                }
            } elseif ($tipo == 2) {
                $personas = DB::select(
                    "SELECT 
                    U.tipo as perfilUsuario,
                    E.idempleado as idempleado,
                    U.nombreusuario as username,
                    E.nombre as nombre,
                    E.direccion as razon,
                    E.email as email,
                    E.rutacv as cv
                    FROM usuario as U 
                    inner join empleado as E on U.idusuario=E.idusuario 
                    where U.nombreusuario='$usuario' and U.clave='$password'"
                );

                if (count($personas) > 0) {
                    foreach ($personas as $value) {
                        $perfilUsuario = $value->perfilUsuario;
                        $idempleado = $value->idempleado;
                        $usuario = $value->username;
                        $verificado = 0;
                        $nombre = $value->nombre;
                        $email = $value->email;
                        $razon = $value->razon;

                        $arr_inciQui[] = [
                            'idempleado' => $idempleado,
                            'idempresa' => '',
                            'usuario' => $usuario,
                            'nombre' => $nombre,
                            'razon' => $razon,
                            'rubro' => '',
                            'email' => $email,
                            'perfilUsuario' => $perfilUsuario,
                        ];
                        $dataenviof = [];
                        $dataenviof['detalle'] = 'ok';
                        $dataenviof['message'] = true;
                        $dataenviof['error'] = false;
                        $dataenviof['data'] = $arr_inciQui;
                    }

                    return response($dataenviof, 200);
                } else {
                    $dataenviof = [];
                    $dataenviof['detalle'] = 'No registrado';
                    $dataenviof['message'] = false;
                    $dataenviof['data'] = '';
                    return response($dataenviof, 200);
                }
            }
        }
    }

    /* 
 INSERT INTO postulaciones ( estado, idempleado, idempleo, fechahora, idempresa, fechavisualizacion) 
 VALUES (NULL, '1', '1', '9', '2022-10-07 01:50:05.000000', '1', 'null');
    */

    public function PostularPostulante(Request $request)
    {
        $idempleado = $request['idempleado'];
        $idempleo = $request['idempleo'];
        $idempresa = $request['idempresa'];

        $validar = DB::select(
            "SELECT * FROM `postulaciones` where idempleado='$idempleado' and idempleo='$idempleo'"
        );

        if (count($validar) == 0) {
            $users1 = DB::insert(
                'insert into postulaciones (estado, idempleado, idempleo, fechahora, idempresa,fechavisualizacion) values (?,?,?,?,?,?)',
                ['1', $idempleado, $idempleo, now(), $idempresa, 'null']
            );

            if ($users1) {
                $dataenviof = [];
                $dataenviof['msj'] = 1;
                $dataenviof['detalle'] = $users1;
                $dataenviof['message'] = true;

                return response($dataenviof, 200);
            } else {
                $dataenviof = [];
                $dataenviof['msj'] = 0;
                $dataenviof['detalle'] = 'fallo';
                $dataenviof['message'] = false;
                return response($dataenviof, 200);
            }
        } else {
            $dataenviof = [];
            $dataenviof['msj'] = 2;
            $dataenviof['detalle'] = 'ya postulado';
            $dataenviof['message'] = true;
            return response($dataenviof, 200);
        }
    }

    public function ActivarCuentadeEmpresa(Request $request)
    {
        $ruc = $request['ruc'];
        $personas = DB::select(
            "select E.idusuario as idusuario from usuario as U
            inner join empresa as E on U.idusuario=E.idusuario where E.ruc='$ruc' limit 1"
        );
        if (count($personas) > 0) {
            foreach ($personas as $value) {
                $idusuario = $value->idusuario;
            }
            $update = DB::update(
                'update usuario set estado = 1 where idusuario = ?',
                [$idusuario]
            );
            echo 'Activada';
        } else {
            echo 'fallo';
        }
    }

    public function botonactivar($ruc)
    {
        $personas = DB::select(
            "select E.idusuario as idusuario from usuario as U
            inner join empresa as E on U.idusuario=E.idusuario where E.ruc='$ruc' limit 1"
        );
        if (count($personas) > 0) {
            foreach ($personas as $value) {
                $idusuario = $value->idusuario;
            }

            /*
           UPDATE `usuario` SET `estado` = '1' WHERE `usuario`.`idusuario` = 9;
           */
            $update = DB::update(
                'update usuario set estado = 1 where idusuario = ?',
                [$idusuario]
            );
            //   echo 'activado';
        } else {
            // echo 'fallo';
        }
    }

    public function EmpleosActivosBuscar(Request $request)
    {
        $nombre = $request['nombre'];

        //
        $personas = DB::select(
            "SELECT E.idempleo as idempleo, EM.idempresa as idempresa, E.nombre as empleo, EM.nombre as empresa,E.pefil descri 
        FROM empleos as E 
        inner join empresa as EM on E.idempresa=EM.idempresa  
        where E.estado=1 and E.nombre LIKE '%$nombre%'  ORDER BY E.fechacreacion ASC"
        );
        if (count($personas) > 0) {
            $response = [
                'data' => $personas,
                'res' => true,
            ];
            return response($response, 200);
        } else {
            $response = [
                'data' => $personas,
                'res' => false,
            ];

            return response($response, 200);
        }
    }

    public function VerEmpleosPostulantes(Request $request)
    {
        $idempresa = $request['idempresa'];

        $personas = DB::select(
            "SELECT * FROM `empleos` where idempresa='$idempresa'"
        );

        if (count($personas) > 0) {
            foreach ($personas as $value) {
                //  $contrv = $contrv + 1; idempleo
                $nombre = $value->nombre;
                $pefil = $value->pefil;
                $fechacreacion = $value->fechacreacion;
                $idempleo = $value->idempleo;
                $estado = $value->estado;

                $alternativasa = DB::select(
                    "SELECT P.idpostulaciones as idpostulaciones, 
                    E.idempleado as idempleado,
                    E.nombre as nombrepostulante,
                    E.rutacv as ruta,
                    E.email as email,
                    E.telefono as telefono,
                    E.direccion as direccion
                   
                    FROM `postulaciones` as P 
                    inner join empleado as E on P.idempleado=E.idempleado 
                    where P.idempleo='$idempleo'"
                );

                if (count($alternativasa) > 0) {
                    foreach ($alternativasa as $valterG) {
                        $idpostulaciones = $valterG->idpostulaciones;
                        $idempleado = $valterG->idempleado;
                        $nombrepostulante = $valterG->nombrepostulante;
                        $email = $valterG->email;
                        $telefono = $valterG->telefono;
                        $ruta = $valterG->ruta;
                        $direccion = $valterG->direccion;

                        $alternativas1G[] = [
                            'idposrulaciones' => $idpostulaciones,
                            'idempleado' => $idempleado,
                            'nombrePostulante' => $nombrepostulante,
                            'email' => $email,
                            'telefono' => $telefono,
                            'direccion' => $direccion,
                            'cv' => $ruta,
                        ];
                    }
                } else {
                    $alternativas1G[] = [];
                }

                //estado
                $arr_inciQui[] = [
                    'idempleo' => $idempleo,
                    'nombreEmpleo' => $nombre,
                    'perfil' => $pefil,
                    'fechaCreacion' => $fechacreacion,
                    'estado' => $estado,
                    'postulantes' => $alternativas1G,
                ];
                unset($alternativas1G);
            }

            $dataenviof = [];
            $dataenviof['res'] = true;
            $dataenviof['data'] = $arr_inciQui;

            return response($dataenviof, 200);
        } else {
            $dataenviof = [];
            $dataenviof['res'] = true;
            $dataenviof['data'] = null;
        }
    }

    public function RegistroEmpleo(Request $request)
    {
        $rules = [
            'idempresa' => 'required|integer',
            'nombre' => 'required|string|unique:empleos,nombre',
            'pefil' => 'required',
        ];
        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            $response = [
                'msj' => false,
                'msg' => 'ok',
                'detalle' => 'error',
                'error' => $validator->errors(),
            ];

            return response($response, 400);
        } else {
            $idempresa = $request['idempresa'];
            $nombre = $request['nombre'];
            $pefil = $request['pefil'];

            $users1 = DB::insert(
                'insert into empleos (idempresa, estado, nombre, idusuario, pefil, fechacreacion, visualizacion) values (?,?,?,?,?,?,?)',
                [$idempresa, '1', $nombre, '0', $pefil, now(), 0]
            );

            $response = [
                'msj' => true,
                'msg' => 'ok',
                'detalle' => $users1,
                'error' => $validator->errors(),
            ];

            return response($response, 200);
        }
    }

    public function ActualizarEmpleo(Request $request)
    {
        $rules = [
            'idempleo' => 'required',
            'nombre' => 'required',
            'estado' => 'required|integer',
            'pefil' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            $response = [
                'msj' => false,
                'msg' => 'ok',
                'detalle' => 'error',
                'error' => $validator->errors(),
            ];

            return response($response, 400);
        } else {
            $idempleo = $request['idempleo'];
            $nombre = $request['nombre'];
            $estado = $request['estado'];
            $pefil = $request['pefil'];
            $personas = DB::select(
                "SELECT * FROM empleos where idempleo=' $idempleo' "
            );

            if (count($personas) > 0) {
                $update = DB::update(
                    "UPDATE empleos SET estado = '$estado', nombre = '$nombre', pefil = '$pefil'
                    WHERE idempleo = ?",
                    [$idempleo]
                );

                $json = [
                    'msj' => true,
                    'msg' => 'ok',
                    'detalle' => $update,
                    'error' => '',
                ];
                return response($json, 200);
            } else {
                $json = [
                    'msj' => true,
                    'msg' => 'ok',
                    'detalle' => 'no encotrado',
                    'error' => '',
                ];
                return response($json, 200);
            }
        }
    }

    /*
  SELECT p.idpostulaciones as idpostulaciones , E.nombre as nombreempleo,EM.nombre as empresa,E.estado FROM `postulaciones` as p inner join empleos as E on p.idempleo=E.idempleo inner join empresa as EM on EM.idempresa=E.idempresa WHERE p.idempleado=3;

  */

    public function verEmpleados()
    {
        $personas = DB::select('SELECT * FROM `trabajado`');
        if (count($personas) > 0) {
            $response = [
                'data' => $personas,
                'res' => true,
            ];
            return response($response, 200);
        } else {
            $response = [
                'data' => $personas,
                'res' => false,
            ];

            return response($response, 200);
        }
    }

    public function RegistrarEmpleado(Request $request)
    {
        $rules = [
            'dni' => 'required|integer|digits:8|unique:trabajado,dni',
            'nombre' => 'required',
            'edad' => 'required',
            //'idestadosatencion' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $response = [
                'msj' => 4,
                'erro' => $validator->errors(),
            ];

            return response($response, 201);
        } else {
            $dni = $request['dni'];
            $nombre = $request['nombre'];
            $edad = $request['edad'];

            $users = DB::select('call Pa_Registra_Empleado(?,?,?)', [
                $dni,
                $nombre,
                $edad,
            ]);

            $response = [
                'msj' => 1,
                'rpta' => $users,
            ];

            return response($response, 201);
        }
    }

    public function ActualizarEmpleado(Request $request)
    {
        $rules = [
            'id' => 'required|integer',
            'nombre' => 'required',
            'edad' => 'required',
            //'idestadosatencion' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $response = [
                'msj' => 4,
                'erro' => $validator->errors(),
            ];

            return response($response, 201);
        } else {
            $dni = $request['id'];
            $nombre = $request['nombre'];
            $edad = $request['edad'];

            $users = DB::select('call Pa_Actualizar_Empleado(?,?,?)', [
                $dni,
                $nombre,
                $edad,
            ]);

            $response = [
                'msj' => 1,
                'rpta' => $users,
            ];

            return response($response, 201);
        }
    }

    public function DeleteEmpleado(Request $request)
    {
        $rules = [
            'id' => 'required|integer',

            //'idestadosatencion' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $response = [
                'msj' => 4,
                'erro' => $validator->errors(),
            ];

            return response($response, 201);
        } else {
            $id = $request['id'];

            $users = DB::select('call Pa_Eliminar_Empleado(?)', [$id]);

            $response = [
                'msj' => 1,
                'rpta' => $users,
            ];

            return response($response, 201);
        }
    }
}
